module MyModule
^^^^^^^^^^^^^^^ RSpec/DescribedClassModuleWrapping: Avoid opening modules and defining specs within them.
  RSpec.describe MyClass do
    subject { "MyClass" }
  end
end

module MyFirstModule
^^^^^^^^^^^^^^^^^^^^ RSpec/DescribedClassModuleWrapping: Avoid opening modules and defining specs within them.
  module MySecondModule
  ^^^^^^^^^^^^^^^^^^^^^ RSpec/DescribedClassModuleWrapping: Avoid opening modules and defining specs within them.
    RSpec.describe MyClass do
      subject { "MyClass" }
    end
  end
end

# ::RSpec.describe (leading ::) inside a module
module MyNamespace
^^^^^^^^^^^^^^^^^ RSpec/DescribedClassModuleWrapping: Avoid opening modules and defining specs within them.
  ::RSpec.describe SomeClass do
    it 'works' do
    end
  end
end

# class nested inside module wrapping RSpec.describe
module VCR
^^^^^^^^^^ RSpec/DescribedClassModuleWrapping: Avoid opening modules and defining specs within them.
  class Cassette
    ::RSpec.describe HTTPInteractionList do
      it 'matches requests' do
      end
    end
  end
end
