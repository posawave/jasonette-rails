module Jasonette
  class JasonSingleton
    private_class_method :new

    def self.fetch context
      if (defined?(@@instance) && @@instance)
        return @@instance if !context.nil? && (instance.context == context)
        reset
      end
      @@instance = Jasonette::Jason.new(context)
    end

    def self.instance
      @@instance
    end

    def self.reset
      @@instance = nil
    end
  end

  module JbuilderExtensions
    def j
      JasonSingleton.fetch(@context)
    end

    def jason &block
      builder = JasonSingleton.fetch(@context)
      builder.with_attributes { instance_eval(&block) }
      _set_value "$jason", builder.attributes!
      self
    end

    def build name, &block
      builder = JasonSingleton.fetch(@context)
      builder.with_attributes { instance_eval(&block) }
      _set_value name, _scope { builder.attributes! }
      self
    end

    # def inline name
    #   builder = JasonSingleton.fetch(@context)
    #   {name => builder.object_id.to_s}.to_json
    # end

    def inline! name
      partial_source = @context.lookup_context.find_file(name, @context.lookup_context.prefixes, true).source
      json = self
      source = <<-RUBY
        json.jason do
          instance_eval(partial_source)
        end
      RUBY

      instance_eval(source)
      self
    end

    # def head &block
    #   builder = Jasonette::Jason::Head.new(@context)
    #   builder.with_attributes { instance_eval(&block) }
    #   set! "head", builder.attributes!
    #   self
    # end

    def template &block
      puts '@' * 40, 'template'

      builder = Jasonette::Jason::Template.new(@context)
      builder.with_attributes { instance_eval(&block) }
      _set_value "template", builder.attributes!
      self
    end

    def body &block
      puts '@' * 40, 'body'

      builder = Jasonette::Jason::Body.new(@context)
      builder.with_attributes { instance_eval(&block) }
      _set_value "body", builder.attributes!
      self
    end
  end

  ::Jbuilder.send(:include, JbuilderExtensions)
end
