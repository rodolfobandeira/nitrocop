before { freeze_time }

around(:all) do |example|
  freeze_time do
    example.run
  end
end

around(:suite) do |example|
  freeze_time do
    example.run
  end
end

around do |example|
  freeze_time do
    do_some_preparation
    example.run
  end
end

# travel_to with time argument and block pass — not autocorrectable to before
around do |ex|
  travel_to(freeze_time, &ex)
end

around { |ex| travel_to(freeze_time, &ex) }

around do |ex|
  Time.use_zone(time_zone) do
    travel_to(start_time, &ex)
  end
end
