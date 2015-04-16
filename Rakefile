require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

Rake::TestTask.new do |t|
  t.name = :tsa
  t.libs << 'test'
  t.test_files = ['test/test_tsa.rb']
end

Rake::TestTask.new do |t|
  t.name = :sim
  t.libs << 'test'
  t.test_files = ['test/test_simulate.rb']
end

Rake::TestTask.new do |t|
  t.name = :eval
  t.libs << 'test'
  t.test_files = ['test/test_evaluate.rb']
end

Rake::TestTask.new do |t|
  t.name = :fastqc
  t.libs << 'test'
  t.test_files = ['test/test_fastqc.rb']
end

desc "Run tests"
task :default => :test
