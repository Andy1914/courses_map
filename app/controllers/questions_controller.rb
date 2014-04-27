class QuestionsController < ApplicationController

 	def index
 		current_user_id = current_user.id
 		if params[:step].present? && [3,4,5].include?(params[:step].to_i) 			 			
 			@answers = Answer.joins("INNER JOIN algorithms on algorithms.id = answers.question_id").where("answers.user_id = #{current_user_id}").select("algorithms.trait,avg(answers.answer) AS answer_avg").order("avg(answers.answer)").group("algorithms.trait").limit(3)
 			if [3,4].include?(params[:step].to_i) 				
 				if @answers.present?
 					@questions = Algorithm.find_by_sql("SELECT t.id, question, trait FROM (SELECT (SELECT id FROM algorithms WHERE trait = "+@answers.first.trait.to_s+" ORDER BY RAND() LIMIT 1) id FROM algorithms t WHERE t.id NOT IN ("+Answer.select('question_id').where("user_id = #{current_user_id}").map(&:question_id).join(',')+") GROUP BY trait LIMIT 2) q JOIN algorithms t ON q.id = t.id ") 					
 					traits = @answers.map(&:trait)
 					traits.delete_at(0)
 					@questions += Algorithm.find_by_sql("SELECT t.id, question, trait FROM (SELECT (SELECT id FROM algorithms WHERE trait = t.trait AND trait IN ("+traits.join(",")+") ORDER BY RAND() LIMIT 1) id FROM algorithms t WHERE t.id NOT IN ("+Answer.select('question_id').where("user_id = #{current_user_id}").map(&:question_id).join(',')+") GROUP BY trait ) q JOIN algorithms t ON q.id = t.id ")
 				end
 			else
 				redirect_to question_path(1,:trait => @answers.pluck(:trait).first(2)) 			 			
 			end 			 			
 		elsif params[:step].present? && params[:step].to_i == 2
 			@questions = Algorithm.find_by_sql("SELECT t.id, question, trait FROM (SELECT (SELECT id FROM algorithms WHERE trait = t.trait ORDER BY RAND() LIMIT 1) id FROM algorithms t WHERE t.id NOT IN ("+Answer.select('question_id').where('user_id = 1').map(&:question_id).join(',')+") GROUP BY trait ) q JOIN algorithms t ON q.id = t.id ")
 		else
	 		params[:step] ||= 1
	 		@questions = Algorithm.find_by_sql("SELECT t.id, question, trait FROM (SELECT (SELECT id FROM algorithms WHERE trait = t.trait ORDER BY RAND() LIMIT 1) id FROM algorithms t GROUP BY trait) q JOIN algorithms t ON q.id = t.id")			
		end
 	end

 	def create
 		if params[:answer].present?
 			if params[:answer].length == 6 && [1,2].include?(params[:step].to_i)
	 			params[:answer].each do |key,value|
	 				@answer = Answer.create(:answer=>value ,:question_id=>key ,:user_id=>current_user.id)
	 			end
	 			redirect_to questions_path( :step => params[:step].to_i+1 ) 
	 		elsif params[:answer].length == 4 && [3,4].include?(params[:step].to_i) 
	 			params[:answer].each do |key,value|
	 				@answer = Answer.create(:answer=>value ,:question_id=>key ,:user_id=>current_user.id)
	 			end
	 			redirect_to questions_path( :step => params[:step].to_i+1 )
	 		else
	 			redirect_to questions_path
	 		end
 		else
	 		redirect_to questions_path
 		end
 	end

 	def show
 		# render :text => "You are #{Algorithm::PERSONALITY_TYPE[params[:trait][0].to_i]} and #{Algorithm::PERSONALITY_TYPE[params[:trait][1].to_i]}".inspect and return false
 	end

 	def requestionare
 		Answer.where(:user_id).try(:destroy_all)
 		redirect_to questions_path,:notice => "New Questionare Started"
 	end

end
