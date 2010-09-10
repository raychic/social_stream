# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

ActivityVerb::Available.each do |value|
  ActivityVerb.find_or_create_by_name value
end

{ 
  'User-User' => [
    { 'Friend' => [
       [ 'create' , 'resources', 'weak_set' ],
       [ 'read',    'resources', 'group_set' ],
       [ 'update' , 'resources', 'weak_set' ],
       [ 'destroy', 'resources', 'weak_set' ] ] },
    { 'FriendOfFriend' => [
        [ 'read',    'resources', 'group_set' ] ] },
    { 'Public' => [
      [ 'read',    'resources', 'group_set' ] ] }
  ],
  'User-Space' => [
    { 'Admin' => [
        [ 'create' , 'resources', 'weak_set' ],
        [ 'read',    'resources', 'group_set' ],
        [ 'update' , 'resources', 'weak_group_set' ],
        [ 'destroy', 'resources', 'weak_group_set' ] ] },
    { 'User' => [
      [ 'create' , 'resources', 'weak_set' ],
      [ 'read',    'resources', 'group_set' ],
      [ 'update' , 'resources', 'weak_group_set' ],
      [ 'destroy', 'resources', 'weak_group_set' ] ] },
    { 'Follower' => [
      [ 'read',    'resources', 'group_set' ] ] }
  ]
}.each_pair do |mode, ordered_rs|
  parent_relation = nil

  ordered_rs.each do |rs|
    rs.each_pair do |name, ps|
      r = Relation.find_by_mode_and_name(mode, name)

      if r.blank?
        r = Relation.create! :name => name,
                             :mode => mode,
                             :parent => parent_relation
      end

      ps.each do |p|
        p = Permission.find_or_create_by_action_and_object_and_parameter(*p)
        r.permissions << p unless r.permissions.include?(p)
      end

      parent_relation = r
    end
  end
end
