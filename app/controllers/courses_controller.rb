class CoursesController < ApplicationController
  # GET /courses
  # GET /courses.json
  include ApplicationHelper
  def index
    if params[:state] == "1"
      @state = 0;
      sort = "DESC"
    else
      @state = 1;
      sort = "ASC"
    end
    scope = Course.visible
    if params[:sorton]
      field = params[:sorton]
    else
      field = 'institution'
    end    
    
    keyword = filter_helper(params)

    order_by = "#{field} #{sort}"
    @courses = scope.paginate(:conditions => keyword, :order => order_by,:per_page=>10,:page=>params[:page])

    @columns = [["Institute","institution@string"],["Title","title@string"],["Instructor","instructor@string"],["Description","description@string"],["Department","section_id@list"]]    
    @nodes = scope.all.map{|x| x.institution[0] if x.institution}.uniq

    @sections = Section.all.map { |e| [e.name,e.id]  }

    # @courses = Course.paginate(:page => params[:page], :per_page => 30) 
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @courses }
    end
  end

  # GET /courses/1
  # GET /courses/1.json
  def show
    @course = Course.find(params[:id])


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @course }
    end
  end

  # GET /courses/new
  # GET /courses/new.json
  def new
    @course = Course.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @course }
    end
  end

  # GET /courses/1/edit
  def edit
    @course = Course.find(params[:id])
  end

  # POST /courses
  # POST /courses.json
  def create
    @course = Course.new(params[:course])

    respond_to do |format|
      if @course.save
        format.html { redirect_to @course, notice: 'Course was successfully created.' }
        format.json { render json: @course, status: :created, location: @course }
      else
        format.html { render action: "new" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /courses/1
  # PUT /courses/1.json
  def update
    @course = Course.find(params[:id])

    respond_to do |format|
      if @course.update_attributes(params[:course])
        format.html { redirect_to @course, notice: 'Course was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    respond_to do |format|
      format.html { redirect_to courses_url }
      format.json { head :no_content }
    end
  end
end
