require_relative 'user'
require_relative 'questions'

class Reply
  attr_accessor :id, :questions_id, :parent_id, :users_id, :body

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def initialize (options)
    @id = options['id']
    @questions_id= options['questions_id']
    @parent_id= options['parent_id']
    @users_id = options['users_id']
    @body = options['body']
  end

  def save
    if @id 
      QuestionsDatabase.instance.execute(<<-SQL, questions_id, parent_id, users_id, body, id)
        UPDATE
          replies
        SET 
          questions_id = ?, parent_id = ?, users_id = ?, body = ?
        WHERE 
          replies.id = ?
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, questions_id, parent_id, users_id, body)
        INSERT INTO
          replies (questions_id, parent_id, users_id, body)
        VALUES
          (?, ?, ?, ?)
      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end

  def self.find_by_id(id)
    reply_data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    return nil if reply_data.nil?
    reply_data.map {|reply| Reply.new(reply) }
  end

  def self.find_by_user_id(user_id)
    reply_data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT 
        *
      FROM
        replies
      WHERE
        replies.users_id = ?
    SQL

    reply_data.map {|reply| Reply.new(reply) }
  end

  def self.find_by_question_id(question_id)
    reply_data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT 
        *
      FROM
        replies
      WHERE
        replies.questions_id = ?
    SQL

    reply_data.map {|reply| Reply.new(reply) }
  end
  
  # The author of the reply
  def author
    User.find_by_id(users_id)
  end
  
  # The question being replied to
  def question
    Question.find_by_id(questions_id)
  end
  
  #
  def parent_reply
    Reply.find_by_id(parent_id)
  end
  
  def child_replies
    replies_data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL

    replies_data.map { |reply| Reply.new(reply) }
  end

end