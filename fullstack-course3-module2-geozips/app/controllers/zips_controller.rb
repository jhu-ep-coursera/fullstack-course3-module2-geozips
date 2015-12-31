class ZipsController < ApplicationController
  before_action :set_zip, only: [:show, :edit, :update, :destroy]

  # GET /zips
  # GET /zips.json
  def index
    #@zips = Zip.all
    #@zips = Zip.paginate(params)

    args=params.clone                      #update a clone of params
    args[:sort]=get_sort_hash(args[:sort]) #replace sort with hash
    @zips = Zip.paginate(args)
    @locations = zip_markers @zips
  end

  # GET /zips/1
  # GET /zips/1.json
  def show
    near_zips=@zip.near(params[:max_miles], params[:min_miles] ,params[:limit])
    @locations=zip_markers near_zips
    p @locations
  end

  # GET /zips/new
  def new
    @zip = Zip.new
  end

  # GET /zips/1/edit
  def edit
  end

  # POST /zips
  # POST /zips.json
  def create
    @zip = Zip.new(zip_params)

    respond_to do |format|
      if @zip.save
        format.html { redirect_to @zip, notice: 'Zip was successfully created.' }
        format.json { render :show, status: :created, location: @zip }
      else
        format.html { render :new }
        format.json { render json: @zip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /zips/1
  # PATCH/PUT /zips/1.json
  def update
    respond_to do |format|
      if @zip.update(zip_params)
        format.html { redirect_to @zip, notice: 'Zip was successfully updated.' }
        format.json { render :show, status: :ok, location: @zip }
      else
        format.html { render :edit }
        format.json { render json: @zip.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /zips/1
  # DELETE /zips/1.json
  def destroy
    @zip.destroy
    respond_to do |format|
      format.html { redirect_to zips_url, notice: 'Zip was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_zip
      @zip = Zip.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def zip_params
      params.require(:zip).permit(:id, :city, :state, :population)
    end

    #create a hash sort spec from query param
    #sort=state:1,city,population:-1
    #{state:1, city:1, population:-1}
    def get_sort_hash(sort)
      order={}
      if (!sort.nil?)
        sort.split(",").each do |term|
          args=term.split(":")
          dir = args.length<2 || args[1].to_i >= 0 ? 1 : -1
          order[args[0]] = dir
        end
      end
      return order
    end

    def zip_markers zips
      #build the marker for the center of the map
      if @zip
        center_marker = Gmaps4rails.build_markers(@zip) do |zip, marker|
          marker.lat zip.latitude
          marker.lng zip.longitude
          marker.infowindow zip.city
          marker.picture(:url=> "/images/marker32.png",
                         :width=>  32,
                         :height=> 32)
        end
      end

      #build markers for map
      marked_zip=@zip.nil?
      locations = Gmaps4rails.build_markers(zips) do |zip, marker|
        marker.lat zip.latitude
        marker.lng zip.longitude
        marker.infowindow zip.city
        #add special marker for target city
        if @zip && zip.id==@zip.id
          marker.picture center_marker[0][:picture]
          marked_zip=true
        end
      end

      #add target city of left out
      locations << center_marker[0]  if !marked_zip
      return locations
    end
end
