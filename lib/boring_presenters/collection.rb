# frozen_string_literal: true

module Boring
  class Collection #:nodoc:
    include Enumerable

    attr_accessor :__collection, :__presenter, :__arguments

    def initialize(**collections)
      self.__presenter = superclass.new
      self.__arguments = presenter.__arguments
      self.__collections = collections.slice(__arguments.keys)
    end

    def each
      size = __collections.values[0].size

      size.times do |i|
        bind_args = __collections.inject({}) do |memo, (k, v)|
          memo[k] = v[i] if v.respond_to?(:size) && v.size > i
        end

        yield __presenter.send(:bind, **bind_args)
      end
    end
  end
end
