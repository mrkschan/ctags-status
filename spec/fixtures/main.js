function func1(arg) {
    return;
}

function func1a(arg)
{
    return;
}

var func2 = function(arg) {
    return;
};

var func2a = function(arg)
{
    return;
};

(function() {
    var func3 = function() {
        return;
    };
    var func3a = function()
    {
        return;
    };
}());

O = {
    func4: function() {
        return;
    },
    func4a: function()
    {
        return;
    }
};

function noop() {}
