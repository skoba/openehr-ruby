
def assert_at(file,line, message = "")
  unless yield
    raise "Assertion failed !: #{file}, #{line}: #{message}"
  end
end
