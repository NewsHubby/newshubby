class HubertController < ApplicationController
  include Wicked::Wizard
    
  steps :basic, :subscription, :logo, :people, :what, :how, :clients, :business_model, :competitors, :differentiation, :funding, :embargo, :launch, :quote, :problem_solved, :files, :links, :congratulations

  def show
    @hubert_body = true
    @newsroom = current_newsroom
    @company_launch = @newsroom.company_launches.last
    
    
    
    if @newsroom.company_launches.last.nil?
      @company_launch = @newsroom.company_launches.create(hex: SecureRandom.urlsafe_base64(6))
  end

    
    # Count number of steps
    
    @steps_newsroom = 11
    @steps_company_launch = 5
    
    # Max steps
    
    if @newsroom.company_launches.count < 2
      @steps_max = @steps_newsroom + @steps_company_launch
    else
      @steps_max = @steps_company_launch
    end
    
    # Step number
    
    if @newsroom.company_launches.count < 2
    
      @step_number = step
    end    

    # Redirect to interview specific question if more than one press release 
    if 1 > 2
      if @newsroom.company_launches.count > 1 && step != :embargo && step != :launch && step != :quote && step != :files  && step != :links
        jump_to(:embargo)
      end
    end
                  
    case step
    
    when :basic
    if @newsroom.company_launches.count < 2
      @step_number = 1
    else 
      skip_step
    end
    
    when :subscription
      
      if @newsroom.subscription.nil? || @newsroom.subscription.end < Time.now 
        @plans = Plan.order("price")
      else
        skip_step
      end
    
    when :logo
      
    # Subscription check
    if @newsroom.subscription.nil? || @newsroom.subscription.end < Time.now
      
      # Payment code check
      @code = @newsroom.code
      @code_match = Code.find_by_code(@code)

      if @code_match != nil
        duration = "#{@code_match.duration}.months"
        @newsroom.create_subscription(plan_id: 1, email: @newsroom.email, end: Time.now + eval(duration) )     # create subscription with end time X months after signup
        @code_match.destroy      # retire code
      else
        jump_to(:subscription)
      end
    
    end
      
    if @newsroom.company_launches.count < 2
      @step_number = 2
    else 
      skip_step
    end
      
    when :people
    if @newsroom.company_launches.count < 2
      @step_number = 3
    else 
      skip_step
    end

    when :what
    if @newsroom.company_launches.count < 2
      @step_number = 4
    else 
      skip_step
    end
  
    when :how
    if @newsroom.company_launches.count < 2
      @step_number = 5
    else 
      skip_step
    end    

    when :clients
    if @newsroom.company_launches.count < 2
      @step_number = 6
    else 
      skip_step
    end    

    when :business_model
    if @newsroom.company_launches.count < 2
      @step_number = 7
    else
      skip_step
    end
    
    when :competitors
    if @newsroom.company_launches.count < 2
      @step_number = 8
    else
      skip_step
    end
    
    when :differentiation
    if @newsroom.company_launches.count < 2
      @step_number = 9
    else 
      skip_step
    end
      
    when :funding
    if @newsroom.company_launches.count < 2
      @step_number = 10
    else 
      skip_step
    end
      
    when :embargo
    if @newsroom.company_launches.count < 2
      @step_number = 11
    else 
      @step_number = 1
    end   

    when :launch
    if @newsroom.company_launches.count < 2
      @step_number = 12
    else 
      @step_number = 2
    end      

    when :quote
    if @newsroom.company_launches.count < 2
      @step_number = 13
    else 
      @step_number = 3
    end      

    when :problem_solved
    if @newsroom.company_launches.count < 2
      @step_number = 14
    else 
      skip_step
    end    

    when :files
    if @newsroom.company_launches.count < 2
      @step_number = 15
    else 
      @step_number = 4
    end

    when :links
    if @newsroom.company_launches.count < 2
      @step_number = 16
    else 
      @step_number = 5
    end 
      
end    

    render_wizard

  def finish_wizard_path
    newsroom_company_launch_path(@newsroom, @newsroom.company_launches.last)
  end

  end
  
  
  def update
    @newsroom = current_newsroom
    @company_launch = @newsroom.company_launches.last
    
    unless @newsroom.people.exists?
      @newsroom.people.create
    end
    
    unless @newsroom.fundings.exists?
      @newsroom.fundings.create
    end

    @newsroom.update(newsroom_params)
    @company_launch = @newsroom.company_launches.last
    unless @company_launch.launch.nil?
      @company_launch.update(title: "#{@newsroom.company_name} launches #{@company_launch.launch.strftime("%B")}")
    end
  #  @newsroom.attributes = params[:newsroom]
    render_wizard @newsroom
  end
  
  private
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def newsroom_params
      params.require(:newsroom).permit(:company_name, :website, :press_phone, :press_email, :founded, :q_who_are_you, :q_what_you_do, :q_how_you_achieve, :q_clients, :logo, :location, :latitude, :longitude, :business_model, :differentiation, :competitors, :problem_solved, :twitter, :code, people_attributes: [:id, :name, :role, :presentation, :founder, :_destroy],  fundings_attributes: [:id, :investment_type, :name, :date, :amount, :_destroy], company_launches_attributes: [:id, :title, :quote, :link1, :link2, :file1, :file2, :file3, :embargo, :launch, :caption_file1, :caption_file2, :caption_file3, :caption_link1, :caption_link2, :_destroy], links_attributes: [:id, :link, :caption, :company_launch_id, :_destroy], uploads_attributes: [:id, :file, :caption, :company_launch_id, :_destroy])
    end
  
end