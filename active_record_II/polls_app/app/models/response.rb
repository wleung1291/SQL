# == Schema Information
#
# Table name: responses
#
#  id               :bigint           not null, primary key
#  answer_choice_id :integer          not null
#  responder_id     :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Response < ApplicationRecord
  belongs_to :answer_choice,
    class_name: 'AnswerChoice',
    primary_key: :id,
    foreign_key: :answer_choice_id

  belongs_to :responder,
    class_name: 'User',
    primary_key: :id,
    foreign_key: :responder_id

  has_one :question,
    through: :answer_choice, # method name/association name above
    source: :question # association in answer_choice model

  # custom validation that ensures the responder has not already answered q
  validate :non_duplicate_responder, unless: -> { answer_choice.nil? }
  # custom validation to ensure author cant answer own poll
  validate :check_poll_author, unless: -> { answer_choice.nil? }

  # return all the other Response objects for the same Question
  # calls associations Response#question and Question#responses
  def sibling_responses
    self.question.responses.where.not(id: self.id)
  end

  # checks to see if any sibling exists? with the same respondent_id.
  def respondent_already_answered?
    sibling_responses.exists?(responder_id: self.responder_id)
  end

  # returns the author of the poll. Calls associations Response#answer_choice, 
  # AnswerChoice#question, and Question#poll
  def poll_author?
    self.answer_choice.question.poll.author_id
  end
  
  
  private
  
  def non_duplicate_responder
    if respondent_already_answered?
      errors[:responder_id] << 'can\'t respond more than once to a question'
    end
  end
  
  def check_poll_author
    if poll_author?
      errors[:responder_id] << 'Author can\'t respond to a question in their poll'
    end
  end

end
