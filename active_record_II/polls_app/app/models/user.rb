# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  username   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ApplicationRecord
  validates :username, presence: true, uniqueness: true
  
  # def authored_polls
  #   Poll.where({author_id: self.id})   
  # end
  has_many :authored_polls,
    primary_key: :id, # users id
    foreign_key: :author_id,
    class_name:  'Poll'

  has_many :responses,
    primary_key: :id,
    foreign_key: :responder_id,
    class_name:  'Response'
  
end
