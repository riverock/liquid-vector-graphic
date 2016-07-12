def sample_output_file
  fixture_file_path("sample_output.svg.liquid")
end

def fixture_file_path(file)
  File.expand_path("../../fixtures/#{file}", __FILE__)
end
