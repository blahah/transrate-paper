require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

Rake::TestTask.new do |t|
  t.name = :tsa
  t.libs << 'test'
  t.test_files = ['test/test_tsa.rb']
end

desc "Run tests"
task :default => :test
