# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

# prevent loading when called by Bundler, only load when called by capistrano
if caller.any? { |callstack_line| callstack_line =~ /^Capfile:/ }
  unless Capistrano::Configuration.respond_to?(:instance)
    abort "capistrano-scoped-variables requires Capistrano 2"
  end

  module Capistrano
    module Configuration
      module VariablesWithScope
        def self.included(base) #:nodoc:
          %w(initialize fetch).each do |m|
            base_name = m[/^\w+/]
            punct     = m[/\W+$/]
            base.send :alias_method, "#{base_name}_without_variable_scope#{punct}", m
            base.send :alias_method, m, "#{base_name}_with_variable_scope#{punct}"
          end
        end
      
        def scope(scope_name, &block)
          @scope.push(scope_name)

          @all_variables[@scope] ||= {}
          @all_original_procs[@scope] ||= {}
          @all_variable_locks[@scope] ||= Hash.new { |h,k| h[k] = Mutex.new }
          @variables = @all_variables[@scope]
          @original_procs = @all_original_procs[@scope]
          @variable_locks = @all_variable_locks[@scope]
        
          value = yield
        
          @scope.pop
        
          @variables = @all_variables[@scope]
          @original_procs = @all_original_procs[@scope]
          @variable_locks = @all_variable_locks[@scope]
        
          value
        end
      
        def scoped(*args, &block)
          args = [:global] if args.empty?
        
          @all_variables[args] ||= {}
          @all_original_procs[args] ||= {}
          @all_variable_locks[args] ||= Hash.new { |h,k| h[k] = Mutex.new }
          @variables = @all_variables[args]
          @original_procs = @all_original_procs[args]
          @variable_locks = @all_variable_locks[args]
        
          value = yield
        
          @variables = @all_variables[args]
          @original_procs = @all_original_procs[args]
          @variable_locks = @all_variable_locks[args]
        
          value
        end

        def fetch_with_variable_scope(variable, *args)
          value = fetch_without_variable_scope(variable, *args)
          unless value || @scope != [ :global ]
            parent_scope = @scope.dup.pop
            value = scoped parent_scope {
              fetch(variable, *args)
            }
          end
          value
        end

        def initialize_with_variable_scope(*args) #:nodoc:
          initialize_without_variable_scope(*args)
          @all_variables = {}
          @all_original_procs = {}
          @all_variable_locks = {}

          @all_variables[:global] = @variables
          @all_original_procs[:global] = @original_procs
          @all_variable_locks[:global] = @variable_locks
        
          @scope = [:global]
        end
        private :initialize_with_variable_scope
      end
    end
  end

  Capistrano::Configuration.send(:include, Capistrano::Configuration::VariablesWithScope)
end