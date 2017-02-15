# DiawiUploader

Ruby script for uploading .ipa files to www.diawi.com

### Usage
```ruby
require_relative 'diawi_uploader'

du = DiawiUploader.new
du.download_link_for_file( path = 'full/path/to/file.ipa',
                           token = 'diawi_token',
                           find_by_udid = 0, 
                           wall_of_apps = 0, 
                           comment = 'Bug fix')
```
