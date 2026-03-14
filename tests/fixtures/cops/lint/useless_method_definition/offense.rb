class Foo
  def bar
  ^^^ Lint/UselessMethodDefinition: Useless method definition detected. The method just delegates to `super`.
    super
  end

  def baz(x, y)
  ^^^ Lint/UselessMethodDefinition: Useless method definition detected. The method just delegates to `super`.
    super(x, y)
  end

  def qux
  ^^^ Lint/UselessMethodDefinition: Useless method definition detected. The method just delegates to `super`.
    super()
  end

  # def self.method with bare super
  def self.class_method
  ^^^ Lint/UselessMethodDefinition: Useless method definition detected. The method just delegates to `super`.
    super
  end

  # def self.method with explicit super(arg)
  def self.class_method_with_args(arg)
  ^^^ Lint/UselessMethodDefinition: Useless method definition detected. The method just delegates to `super`.
    super(arg)
  end

  # method with keyword rest (**kwargs) just calling super
  def method_with_kwrest(**kwargs)
  ^^^ Lint/UselessMethodDefinition: Useless method definition detected. The method just delegates to `super`.
    super
  end

  # method with keyword rest forwarding super(**kwargs)
  def method_with_kwrest_forwarding(**kwargs)
  ^^^ Lint/UselessMethodDefinition: Useless method definition detected. The method just delegates to `super`.
    super(**kwargs)
  end

  # method with block arg forwarding
  def method_with_block(&block)
  ^^^ Lint/UselessMethodDefinition: Useless method definition detected. The method just delegates to `super`.
    super(&block)
  end

  # access modifier wrapper — still flagged
  private def private_method
          ^^^ Lint/UselessMethodDefinition: Useless method definition detected. The method just delegates to `super`.
    super
  end

  protected def protected_method
            ^^^ Lint/UselessMethodDefinition: Useless method definition detected. The method just delegates to `super`.
    super
  end

  class << self
    def other_class_method
    ^^^ Lint/UselessMethodDefinition: Useless method definition detected. The method just delegates to `super`.
      super
    end

    def other_class_method_with_args(arg)
    ^^^ Lint/UselessMethodDefinition: Useless method definition detected. The method just delegates to `super`.
      super(arg)
    end
  end
end
