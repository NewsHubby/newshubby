class CompanyLaunchesController < ApplicationController
  before_action :set_company_launch, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_newsroom!, except: [:index, :show]
  
  # GET /company_launches
  # GET /company_launches.json
  def index
    @newsroom = Newsroom.friendly.find(params[:newsroom_id])
    
    # Show exclusive press releases only to owner
    
    unless @newsroom.company_name == current_newsroom.company_name
      @company_launches = @newsroom.company_launches.where(exclusive: false)
    else
      @company_launches = @newsroom.company_launches.all
    end
    
  end

  def type
    @about_body = true
  end

  # GET /company_launches/1
  # GET /company_launches/1.json
  def show
    @no_body = true
    @pr_body = true
    @newsroom = Newsroom.friendly.find(params[:newsroom_id])

    if @blocked == true
      redirect_to :root
    end
    
    # Not paid
    # Disable header
    @disable_header == true
    
  end
  
  # GET /company_launches/new
  def new    
    @newsroom = Newsroom.friendly.find(params[:newsroom_id])
     hex = SecureRandom.urlsafe_base64(6)
    
     # Subscription ended?
     if @newsroom.subscription.end < Time.now
       redirect_to plans_path
     
     else
     
    @company_launch = current_newsroom.company_launches.create(company_name: @newsroom.company_name, website: @newsroom.website, press_phone: @newsroom.press_phone, press_email: @newsroom.press_email, founded: @newsroom.founded, hex: hex)
    
    current_newsroom.company_launches.last.links.create
    current_newsroom.company_launches.last.uploads.create

    redirect_to hubert_index_path
    
    end
    
  end

  # GET /company_launches/1/edit
  def edit
    @company_launches = current_newsroom.company_launches.friendly.find(params[:id])    
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "Not yours to edit!"
    redirect_to :root
  end

  # POST /company_launches
  # POST /company_launches.json
  def create
    @newsroom = Newsroom.friendly.find(params[:newsroom_id])
    @company_launch = @newsroom.company_launches.create(company_launch_params)
    
    # Set attributes for company_launch if Newsroom already filled out
    # Remember to write if clause
    
    @company_launch.assign_attributes(company_name: @newsroom.company_name, website: @newsroom.website, press_phone: @newsroom.press_phone, press_email: @newsroom.press_email, founded: @newsroom.founded)
    
    respond_to do |format|
      if @company_launch.save
        format.html { redirect_to [@company_launch.newsroom, @company_launch], notice: 'Company launch was successfully created.' }
        format.json { render :show, status: :created, location: @company_launch }
      else
        format.html { render :new }
        format.json { render json: @company_launch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /company_launches/1
  # PATCH/PUT /company_launches/1.json
  def update
    
    respond_to do |format|
      if @company_launch.update(company_launch_params)
        
        @newsroom.update(title: "#{@company_launch.newsroom.company.name} launches #{@company_launch.newsroom.launch}")
        format.html { redirect_to [@company_launch.newsroom, @company_launch], notice: 'Company launch was successfully updated.' }
        format.json { render :show, status: :ok, location: @company_launch }
      else
        format.html { render :edit }
        format.json { render json: @company_launch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /company_launches/1
  # DELETE /company_launches/1.json
  def destroy
    @company_launches = current_newsroom.company_launches.friendly.find(params[:id])
    @company_launch.destroy
    respond_to do |format|
      format.html { redirect_to newsroom_company_launch_url, notice: 'Company launch was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company_launch
      @company_launch = CompanyLaunch.friendly.find(params[:id])
      
      
      # Block exclusive press releases for everyone but owner and hex
      unless @company_launch.exclusive == false || @company_launch.hex == params[:hex] || @company_launch.exclusive == true && current_newsroom.company_name == @company_launch.newsroom.company_name
        @blocked = true
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_launch_params
      params.require(:company_launch).permit(:title, :newsroom_id, :exclusive, :hex, :quote, :link1, :link2, :file1, :file2, :file3, :embargo, :launch, :caption_file1, :caption_file2, :caption_file3, :caption_link1, :caption_link2, :_destroy, newsroom_attributes: [:company_name, :website, :press_email, :press_phone], link_attributes: [:caption, :link, ])
    end
end