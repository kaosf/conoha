# vim: ft=ruby

# @param [String] m1 e.g. 'foo/bar/a' when the matched string is 'lib/foo/bar/a.rb'
# @return [String] e.g. 'test/foo/bar/test_a.rb' when m1 is 'foo/bar/a'
def lib2test(m1)
  "test/#{File.dirname m1}/test_#{File.basename m1}.rb"
end

guard :minitest do
  watch('test/test_helper.rb') { 'test' }
  watch('test/test_conoha.rb')
  watch('lib/conoha.rb') { 'test/test_conoha.rb' }
  watch(%r{^test/.+\/test_.+\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| lib2test m[1] }
end
