# MediaParser

## Description
A simple utility for identifying different types of media based upon naming conventions.

## Usage

Detect type of media based on its name:

      name = 'Popular.TV.Show.S01E03.With.An.Episode.Title.720p.HDTV.x264-GROUP'
      if MediaParser::media_type_for_name(media) == :tv
        # ...
      end
  
Parse detail out of the media name:

      details = MediaParser::media_details_for_name(name)
      if details[:season] > 2 and details[:episode] > 0:
        # ...
      end

## License
[MIT](LICENSE.txt)

## Contact
[Brian Partridge](http://brianpartridge.name) - [@brianpartridge](http://twitter.com/brianpartridge)