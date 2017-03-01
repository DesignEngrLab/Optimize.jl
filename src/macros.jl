#=
  Destructure an object into variables, i.e.

  ```
  type Foo
    a:Int
    b:Int
  end

  foo = Foo(1, 2)

  @fields a, b = foo

  a, b # 1, 2
  ```
=#
macro fields(ex)
  lhs, rhs = ex.args
  block = Expr(:block)
  for field in lhs.args
    push!(block.args, :($(esc(field)) = $(rhs).$field))
  end
  return block
end
