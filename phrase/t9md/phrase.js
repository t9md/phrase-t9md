//  Phrase: translate text
// ======================================================================
var http = require('http');
 
var url = ('ajax.googleapis.com')
var google = http.createClient(80, url);
 
var text = "Hello World from node!";
var requestUrl = '/ajax/services/language/translate?v=1.0&q=' + 
                 escape(text) + '&langpair=en%7Cja'
var request = google.request('GET', requestUrl, {host: "ajax.googleapis.com"});
request.end();
 
request.addListener('response', function (response) {
    var body = '';

    response.addListener('data', function (chunk) {
      body += chunk;
      });

    response.addListener("end", function() {
      var jsonData = JSON.parse(body);
      // console.log(jsonData.responseData.translatedText);
      console.log(jsonData.responseData.translatedText);
      })

});

// Phrase: using jQuery on ServerSide with jsdom [node]
//==============================================
var request = require('request'),
    jsdom = require('jsdom'),
    sys = require('sys'),
    print = sys.print;

var jquery_location = '/Users/maeda_taku/Dropbox/JavaScript/jQuery/lib/jQueryUI/js/jquery-1.4.2.min.js'


request({uri:'http://www.google.com'}, function(error, response, body) {
    if (!error && response.statusCode == 200) {
      var window = jsdom.createWindow(body);
      jsdom.jQueryify(window, jquery_location, function(window, $) {
        $('.gb1').each(function() {
          print(this);
        });
      });
      // sys.puts(body);
    }
});


// Phrase: List up all properties
//==============================================
Object.prototype.printProperties = function (func, include_parent) {
  for (prop in this) {
    if (func(typeof this[prop])) print(prop+ ": " + this[prop]);
  };
};

Object.prototype.printAttributes = function () {
  this.printProperties(function(type) { return type !== 'function' })
};
Object.prototype.printFunctions = function () {
  this.printProperties(function(type) { return type === 'function' })
};

// Phrase: closured variable is shared in inner function
//==============================================
// Bad code, misunderstood as div_id is private to inner function.

divs = window.document.getElementsByTagName('div')

for (var i = 0; i < divs.length; i++) {
  var div_id = divs[i].id;
  divs[i].onmouseover = function() {
    show_element_id(div_id);
  };
};

// Well undestand
for (var i = 0; i < divs.length; i++) {
  var div_id = divs[i].id;
  divs[i].onmouseover = function(id) {
    return function() {
      show_element_id(id);
    }
  }(div_id);
};

// Phrase: later method to all object [ node ]
//==============================================
var print = require('sys').print
var p = print
Object.prototype.later = function (msec, method ) {
  var self = this,
      args = Array.prototype.slice.apply(arguments, [2]);

  if (typeof method === 'string') {
    method = self[method];
  }

  setTimeout(function() {
    method.apply(self, args);
  }, msec);

  return self;
};
var animal = {
  late_hello: function(name) {
    later(1000, function() { print("hello" + name) })
  }
}
animal.late_hello("dog")

// Phrase: object's cloning with constructor
//==============================================
function Animal (name) {
  this.name = name
};
dog = new Animal("Dog");
// constructor is reference to the function object
print("Constructor:\n--\n" + dog.constructor + "\n--\n")
cat = new (dog.constructor)("Cat");

print(dog.name);
print(cat.name);

function clone (obj) {
  obj = new (obj.constructor)(arguments[1])
  return obj
};
lion = clone(dog, "Lion");
print(lion.name);

// Phrase: get self anywhere
//==============================================
var global = this;
var alert = print

global.__defineGetter__("self", function _() {
    return _.caller || global;
});

function foo() {
    alert(self);
}
foo();

// Phrase: Simple http server
//==============================================
var http = require('http');
http.createServer(function(req, res){
        res.writeHead(200, {'Content-Type': 'text/plain'});
        res.end('Hello World\n');
        }).listen(8124, "127.0.0.1");
// console.log('Server running at http://127.0.0.1:8124/');

// Phrase: [sample] setInterval and SIGNAL
//==============================================
puts = require("sys").puts;
setInterval(function () {
        puts("hello");
        }, 500);
process.addListener("SIGINT",
        function () {
            puts("good bye");
            process.exit(0)

// Phrase: [sample] process object
//==============================================
puts = require("sys").puts;
puts(process.pid);
puts(process.ARGV);
puts(process.ENV);
puts(process.cwd());
puts(process.memoryUsage()); // ??
process.exit(0);
});

