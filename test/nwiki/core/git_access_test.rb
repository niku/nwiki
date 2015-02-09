require "nwiki"
require "test/unit"

class GitAccessTest < Test::Unit::TestCase
  def setup
    @subject = ::Nwiki::Core::GitAccess.new("spec/examples/sample.git")
  end

  test "#title" do
    assert 'ヽ（´・肉・｀）ノログ' == @subject.title
  end

  test "#subtitle" do
    assert "How do we fighting without fighting?" == @subject.subtitle
  end

  test '#author' do
    assert "niku" == @subject.author
  end

  test "#find_file" do
    assert "* b\n\n" == @subject.find_file { |path| path == '1/2/b.org' }.text
  end
end
