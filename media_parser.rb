class MediaParser
  def self.media_type_for_name(name)
    # Identify concrete media types which can be parsed.
    detected_types = self.concrete_media_types.select { |type| self.media_details_for_name_type(name, type) }
    resolved_types = self.types_by_resolving_ambiguity_between_types(detected_types)
    
    case resolved_types.count
    when 0
      # Unable to identify media type.
      :unknown
    when 1
      resolved_types[0]
    else
      # Identified as multiple media types.
      :ambiguous
    end
  end
  
  def self.media_details_for_name(name)
    self.media_details_for_name_type(name, self.media_type_for_name(name))
  end
  
  def self.concrete_media_types
    [:tv, :movie, :music, :audio_book, :ebook]
  end
  
  def self.media_type_to_s(type)
    case type
    when :tv
      return 'tv show'
    when :movie
      return 'movie'
    when :music
      return 'music'
    when :audio_book
      return 'audio book'
    when :ebook
      return 'ebook'
    when :ambiguous
      return 'ambiguous'
    else
      return 'unknown'
    end
  end
  
  private
  
  def self.media_details_for_name_type(name, type)
    # Detect media details (if any) for the specified media type.
    case type
    when :tv
      return tv_media_details_for_name(name)
    when :movie
      return movie_media_details_for_name(name)
    when :music
      return music_media_details_for_name(name)
    else
      return nil
    end
  end
  
  def self.types_by_resolving_ambiguity_between_types(ambiguous_types)
    if ambiguous_types == [:tv, :movie]
      # If a media name is detected as both tv and movie, it's probably actually a tv show with a year at the end of the title.
      return [:tv]
    end
    
    ambiguous_types
  end
  
  # TV Show
  def self.tv_media_details_for_name(name)
    # Matches: this.is.a.title.s##.e##.whatever capturing title, season number, and episode number
    matches = /(?<title>.+)[\._ \-][Ss](?<season>\d+)[EeXx](?<episode>\d{2})[\._ \-]/.match(name)
    if matches
      return { type: :tv, title: matches['title'], season: matches['season'].to_i, episode: matches['episode'].to_i }
    end
    
    # Matches: this.is.a.title.s##.whatever capturing title, and season number
    matches = /(?<title>.+)[\._ \-][Ss](?<season>\d+)[\._ \-]/.match(name)
    if matches
      return { type: :tv, title:  matches['title'], season: matches['season'].to_i }
    end
    
    return nil
  end
  
  # Movie
  def self.movie_media_details_for_name(name)
    # Matches: this.is.a.title.1900.whatever capturing title, and year
    matches = /(?<title>.+)[\._ \-](?<year>(19|20)\d{2})[\._ \-]/.match(name)
    if matches
      return { type: :movie, title:  matches['title'], year: matches['year'].to_i }
    end
    
    return nil
  end

  # Music
  def self.music_media_details_for_name(name)
    # Matches: artist-album (year) - v# capturing artist, album, and year
    matches = /(?<artist>.*)\s-\s(?<album>.*)\s\((?<year>(19|20)\d{2})\)\s-\s.*V\d/.match(name)
    if matches
      return { type: :music, artist: matches['artist'], album: matches['album'], year: matches['year'].to_i }
    end
    
    return nil
  end
  
end

# Tests

def verify_is_media_type(media, type)
  type_name = MediaParser::media_type_to_s(type)
  actual_type = MediaParser::media_type_for_name(media)
  if actual_type == type
    puts "✓ media: #{media} type: #{type_name}"
  else
    actual_type_name = MediaFile::media_type_to_s(actual_type)
    raise "✗ media: #{media} type: #{actual_type_name} expected: #{type_name}"
  end
end

def verify_media_details(media, expected_details)
  actual_details = MediaParser::media_details_for_name(media)
  if expected_details == actual_details
    puts "✓ media: #{media} details: #{actual_details}"
  else
    raise "✗ media: #{media} details: #{actual_details} expected: #{expected_details}"
  end
end

def test_media(media, expected_type, expected_details)
  verify_is_media_type(media, expected_type)
  verify_media_details(media, expected_details)
end

test_media = { 
  ## TV
  'Archer.2009.S06E03.720p.HDTV.x264-SCENE.mkv' => { type: :tv, details: { type: :tv, title: 'Archer.2009', season: 6, episode: 3 } },
  'Its.Always.Sunny.in.Philadelphia.S10E02.720p.HDTV.x264-SCENE.mkv' => { type: :tv, details: { type: :tv, title: 'Its.Always.Sunny.in.Philadelphia', season: 10, episode: 2 } },
  'The.Venture.Bros.S06.Special.All.This.and.Gargantua-2.720p.WEB-DL.DD5.1.H.264-SCENE.mkv' => { type: :tv, details: { type: :tv, title: 'The.Venture.Bros', season: 6 } },
  'Marvels.Agents.of.S.H.I.E.L.D.S02E08.720p.HDTV' => { type: :tv, details: { type: :tv, title: 'Marvels.Agents.of.S.H.I.E.L.D', season: 2, episode: 8 } },
  
  ## Movies
  'I.Heart.Huckabees.2004.720p.HDTV.AC3.x264-SCENE' => { type: :movie, details: { type: :movie, title: 'I.Heart.Huckabees', year: 2004 } },
  '2001.A.Space.Odyssey.1968.1080p.BluRay.x264-SCENE' => { type: :movie, details: { type: :movie, title: '2001.A.Space.Odyssey', year: 1968 } },
  '8 1-2 1963 1080p Blu-ray AVC LPCM 1.0-SCENE' => { type: :movie, details: { type: :movie, title: '8 1-2', year: 1963 } },
  'This is a fake media name ending with a year 2015.' => { type: :movie, details: { type: :movie, title: 'This is a fake media name ending with a year', year: 2015 } },
  'This is a fake media name with a year 2015 in the middle.' => { type: :movie, details: { type: :movie, title: 'This is a fake media name with a year', year: 2015 } },
  
  ## Music
  'Hans Zimmer - Interstellar (2014) - V0' => { type: :music, details: { type: :music, artist: 'Hans Zimmer', album: 'Interstellar', year: 2014 } },
  'Jon Hopkins - Asleep Versions (2014) - WEB V0' => { type: :music, details: { type: :music, artist: 'Jon Hopkins', album: 'Asleep Versions', year: 2014 } },
  
  ## TODO Audio Book

  ## TODO Ebook
  
  ## TODO Ambiguous
  
  ## Unknown
  'This is a fake media name.' => { type: :unknown },
}

test_media.each do |media, config|
  test_media(media, config[:type], config[:details])
end
