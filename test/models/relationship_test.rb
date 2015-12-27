require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  def setup
    @relationship = Relationship.new(followed_id: 1, follower_id: 2)
  end
  
  test "should be valid" do
    assert @relationship.valid?    
  end
  
  test "should require a follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end
  
  test "should require a followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end
end
