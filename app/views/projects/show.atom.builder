atom_feed do |feed|
  feed.title "SentimentHub" 
  feed.updated @feedbacks.first.created_at
  @feedbacks.each do |feedback|
  
    feed.entry(feedback, 
               :id => feedback.id, 
               :url => feedback.url) do |entry|
      entry.title     feedback.text_description
      entry.published feedback.created_at
      entry.content   feedback.html_description, :type => 'html'
      entry.updated   feedback.created_at
      entry.link      :type => "image/png", :rel => "image", :href => feedback.author_image
      entry.author do |author|
        author.name  "#{feedback.author_name}"
        author.uri   "#{feedback.author_url}"
      end
    end
  end
end
