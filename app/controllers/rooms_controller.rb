class RoomsController < ApplicationController
  # GET /rooms
  # GET /rooms.xml
  def index

    @hostels = Hostel.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rooms }
    end
  end

  # GET /rooms/1
  # GET /rooms/1.xml
  def show
    @room = Room.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @room }
    end
  end

  # GET /rooms/new
  # GET /rooms/new.xml
  def new
    @room = Room.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @room }
    end
  end

  # GET /rooms/1/edit
  def edit
    @room = Room.find(params[:id])
  end

  # POST /rooms
  # POST /rooms.xml
  def create
    @room = Room.new(params[:room])

    respond_to do |format|
      if @room.save

        number_of_rooms = params[:room][:number_of_rooms].to_i
        if number_of_rooms > 0
          i = @room.room_number + 1

          while i < @room.room_number + number_of_rooms
            room = Room.new(:hostel_id => @room.hostel.id, :students_per_room => @room.students_per_room, :room_number => i, :rent_in_bucks => @room.rent_in_bucks)
            room.save
          	i = i + 1
          end

        else

        end

        flash[:notice] = 'Room was successfully created.'
        format.html { redirect_to(@room) }
        format.xml  { render :xml => @room, :status => :created, :location => @room }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @room.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rooms/1
  # PUT /rooms/1.xml
  def update
    @room = Room.find(params[:id])

    respond_to do |format|
      if @room.update_attributes(params[:room])
        flash[:notice] = 'Room was successfully updated.'
        format.html { redirect_to(@room) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @room.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.xml
  def destroy
    @room = Room.find(params[:id])
    @room.destroy

    respond_to do |format|
      format.html { redirect_to(rooms_url) }
      format.xml  { head :ok }
    end
  end

  def allocation
  end

  def allocation_student
    @student = Student.find(params[:id])
    @hostels = Hostel.all
  end

  def show_rooms_list
    unless params[:id].nil?
      @hostel = Hostel.find(params[:id])
      @student = Student.find(params[:student_id])
      render :update do |page|
        page.replace_html 'rooms', :partial => 'rooms_list'
      end
    end
  end

  def allocate
    @room = Room.find(params[:room_id])
    @student = Student.find(params[:student_id])

    if @student.rooms.count > 0
      flash[:notice] = "A room already allocated to #{@student.full_name}"
      render :js => "window.location = '/rooms/allocation'"
    elsif @room.availability <= 0
      flash[:notice] = "Room not available"
      render :js => "window.location = '/rooms/allocation_student/#{@student.id}'"
    else
      @room.students << @student
      @room.save
      flash[:notice] = "Room allocated to #{@student.full_name}"
      render :js => "window.location = '/rooms/allocation'"
    end
  end
end
