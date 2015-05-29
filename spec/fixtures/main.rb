class Main
    attr_accessor :flag

    def method
        'string'
    end
end

def func
    1
end

def outer
    inner = lambda do |i|
        i
    end

    inner(1)
end
