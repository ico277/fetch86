distro_art_table:
    dd 'arch'      
    dd arch_art 
    dd 'arti'      
    dd artix_art 
    dd 'gent'      
    dd gentoo_art 
    dd 0          ; terminator

    arch_art:   incbin ./resources/arch.bin
    artix_art:  incbin ./resources/artix.bin
    gentoo_art: incbin ./resources/gentoo.bin
