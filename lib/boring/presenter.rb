module Boring
  class Presenter
    extend Forwardable

    @__arguments = {}
    class << self
      attr_accessor :__arguments

      def arguments(args)
        @__arguments = args

        class_eval do
          unless method_defined?(:initialize)
            define_method(:initialize) do |**bindings|
              # dies if nil or empty
              self.class.__arguments.each do |arg_name, arg_class|
                arg_value = bindings[arg_name]

                # Ensure all of our bindings are the appropriate type
                if bindings.key?(arg_name) && !arg_value.is_a?(arg_class)
                  raise ArgumentError, "Argument '#{arg_name}' is of type #{arg_value.class}, expecting #{arg_class}."
                end

                instance_variable_set("@#{arg_name}", arg_value)
              end

              # Ensure we don't have any unexpected arguments
              extra_bindings = (bindings.keys - args.keys)

              unless extra_bindings.empty?
                raise ArgumentError, "Unexpected argument: #{extra_bindings.join(', ')}."
              end
            end
          end

          unless method_defined?(:bind)
            define_method(:bind) do |**bindings|
              self.class.__arguments.each.each do |arg_name, arg_class|
                arg_value = bindings[arg_name]

                unless arg_value.is_a?(arg_class)
                  raise ArgumentError, "Argument '#{arg_name}' is of type #{arg_value.class}, expecting #{arg_class}."
                end

                instance_variable_set("@#{arg_name}", arg_value)
              end
            end
          end

          # TODO: Move to rails extension helper
          # unless method_defined?(:render)
          #   define_method(:render) do |**render_args|
          #     view_context.render(**render_args)
          #   end
          # end

          # unless method_defined?(:view_context)
          #   define_method(:view_context) do
          #     @__view_context ||= ActionView::Base.new(
          #       ActionController::Base.view_paths,
          #       {}
          #     )
          #   end
          # end

          private

          attr_reader(*args.keys)
        end
      end

      def method_added(method_name)
        return if self == Boring::Presenter
        return if @__last_methods_added && @__last_methods_added.include?(method_name)

        skipped_methods = %i[initialize render bind]
        return if skipped_methods.include?(method_name)

        skipped_methods = @__arguments.keys
        return if skipped_methods.include?(method_name)

        with = :"#{method_name}_with_before_each_method"
        without = :"#{method_name}_without_before_each_method"

        @__last_methods_added = [method_name, with, without]
        define_method with do |*args, &block|
          before_each_method method_name
          send without, *args, &block
        end

        alias_method without, method_name
        alias_method method_name, with

        @__last_methods_added = nil
      end

      def delegate(*methods)
        options = methods.pop

        unless options.is_a?(Hash) && to = options[:to]
          raise ArgumentError, 'Delegation needs a target. Supply an options hash with a :to key as the last argument.'
        end

        def_delegators(to, *methods)
      end
    end

    def before_each_method(*)
      # Ensure everything is properly bound before invoking this method
      self.class.__arguments.each do |arg_name, arg_class|
        arg_value = send(arg_name.to_sym)

        if arg_name.nil?
          raise ArgumentError, "Argument '#{arg_name}' is not bound."
        end

        unless arg_value.is_a?(arg_class)
          raise ArgumentError, "Argument '#{arg_name}' is of type #{arg_value.class}, expecting #{arg_class}."
        end
      end
    end
  end
end
