# == Schema Information
#
# Table name: polls
#
#  id         :bigint           not null, primary key
#  title      :string           not null
#  author_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Poll < ApplicationRecord
  validates :title, presence: true

  # def author
  #   User.find(author_id)
  # end
  belongs_to :author,
    class_name: 'User',
    primary_key: :id, # user's id
    foreign_key: :author_id # from polls table
  
  has_many :questions,
    primary_key: :id,
    foreign_key: :poll_id,
    class_name: 'Question'

end
