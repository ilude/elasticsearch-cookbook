name             'elasticsearch'
maintainer       'Mike Glenn'
maintainer_email 'mglenn@ilude.com'
license          'All rights reserved'
description      'Installs/Configures elasticsearch'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "apt"
depends 'build-essential'
depends 'sysstat'
depends 'ruby_build'
depends 'rvm'
depends "bluepill"
