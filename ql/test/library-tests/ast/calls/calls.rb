# call with no receiver, arguments, or block
foo()

# call whose name is a scope resolution
Foo::bar()

# call with a receiver, no arguments or block
123.bar

# call with arguments
foo 0, 1, 2

# call with curly brace block
foo { |x| x + 1 }

# call with do block
foo do |x|
  x + 1
end

# call with receiver, arguments, and a block
123.bar('foo') do |x|
  x + 1
end

# a yield call
def method_that_yields
  yield
end

# a yield call with arguments
def another_method_that_yields
  yield 100, 200
end

# ------------------------------------------------------------------------------
# Calls without parentheses or arguments are parsed by tree-sitter simply as
# `identifier` nodes, so here we test that our AST library correctly represents
# them as calls in all the following contexts.

# root level (child of program)
foo

# in a parenthesized statement
(foo)

# in an argument list
some_func(foo)

# in an array
[foo]

# RHS of an assignment
var1 = foo

# RHS an operator assignment
var1 += bar

# RHS assignment list
var1 = foo, bar

# in a begin-end block
begin
  foo
end

# in a BEGIN block
BEGIN { foo }

# in an END block
END { foo }

# both operands of a binary operation
foo + bar

# unary operand
!foo

# in a curly brace block
foo() { bar }

# in a do-end block
foo() do bar end

# the receiver in a call can itself be a call
foo.bar()

# the value for a case expr
# and the when pattern and body
case foo
when bar
  baz
end

# in a class definition
class MyClass
  foo
end

# in a superclass
class MyClass < foo
end

# in a singleton class value or body
class << foo
  bar
end

# in a method body
def some_method
  foo
end

# in a singleton method object or body
def foo.some_method
  bar
end

# in the default value for a keyword parameter
def method_with_keyword_param(keyword: foo)
end

# in the default value for an optional parameter
def method_with_optional_param(param = foo)
end

# in a module
module SomeModule
  foo
end

# ternary if: condition, consequence, and alternative can all be calls
foo ? bar : baz

# if/elsif/else conditions and bodies
if foo
  wibble
elsif bar
  wobble
else
  wabble
end

# if-modifier condition/body
bar if foo

# unless condition/body
unless foo
  bar
end

# unless-modifier condition/body
bar unless foo

# while loop condition/body
while foo do
  bar
end

# while-modifier loop condition/body
bar while foo

# until loop condition/body
until foo do
  bar
end

# until-modifier loop condition/body
bar until foo

# the collection being iterated over in a for loop, and the body
for x in bar
  baz
end

# in an array indexing operation, both the object and the index can be calls
foo[bar]

# interpolation
"foo-#{bar}"

# the scope in a scope resolution
foo::Bar

# in a range
foo..bar

# the key/value in a hash pair
{ foo => bar }

# rescue exceptions and ensure
begin
rescue foo
ensure bar
end

# rescue-modifier body and handler
foo rescue bar

# block argument
foo(&bar)

# splat argument
foo(*bar)

# hash-splat argument
foo(**bar)

# the value in a keyword argument
foo(blah: bar)