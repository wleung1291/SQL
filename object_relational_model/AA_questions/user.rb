require_relative 'questions'
require_relative 'reply'
require_relative 'question_follow'
require_relative 'question_like'

class User
  attr_accessor :id, :fname, :lname

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end
  
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname= options['lname']
  end

  def save
    if @id 
      QuestionsDatabase.instance.execute(<<-SQL, fname, lname, id)
        UPDATE
          users
        SET 
          fname = ?, lname = ?
        WHERE 
          users.id = ?
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
        INSERT INTO
          users (fname, lname)
        VALUES
          (?, ?)
      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end

  def self.find_by_id(id)
    user_data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    return nil if user_data.nil?
    user_data.map {|user| User.new(user) }
  end
  
  def self.find_by_name(fname, lname)
    user_name = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM 
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    
    return nil if user_name.nil?
    user_name.map {|name| User.new(name)}
  end

  # User's questions
  def authored_questions  
    Question.find_by_author_id(id)
  end

  # User's replies to questions
  def authored_replies 
    Reply.find_by_user_id(id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(id)
  end

  def liked_questions

  end
end