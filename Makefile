include theos/makefiles/common.mk

TWEAK_NAME = PhotosToAll
PhotosToAll_FILES = Tweak.xm
PhotosToAll_FRAMEWORKS = Foundation UIKit
PhotosToAll_PRIVATE_FRAMEWORKS =  PhotoLibrary PhotoLibraryServices PhotosUI

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileSlideShow"
