# name: discourse-solution-automation
# about: Posts a customizable message when a topic solution is accepted
# version: 1.0
# authors: SergJohn

enabled_site_setting :solution_automation_enabled

after_initialize do
  # Listen to accepted_solution event
  DiscourseEvent.on(:accepted_solution) do |post|
    # Only run if enabled
    next unless SiteSetting.solution_automation_enabled

    # Get message from site setting
    message = SiteSetting.solution_automation_message.presence || "Thanks for the solution!"

    # Prevent duplicates
    already_posted = Post.exists?(
      topic_id: post.topic_id,
      user_id: Discourse.system_user.id,
      raw: message
    )
    next if already_posted

    # Create the post as system user
    PostCreator.create!(
      Discourse.system_user,
      topic_id: post.topic_id,
      raw: message
    )

    Rails.logger.info("Solution automation: post created in topic ##{post.topic_id}")
  end
end
