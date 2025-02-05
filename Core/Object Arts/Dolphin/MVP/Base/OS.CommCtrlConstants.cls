﻿"Filed out from Dolphin Smalltalk"!

Kernel.SharedPool
	subclass: #'OS.CommCtrlConstants'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {
			'ACM_OPEN' -> 16r464.
			'ACM_PLAY' -> 16r465.
			'ACM_STOP' -> 16r466.
			'ACS_AUTOPLAY' -> 16r4.
			'ACS_CENTER' -> 16r1.
			'ACS_TRANSPARENT' -> 16r2.
			'CCM_FIRST' -> 16r2000.
			'CCM_GETCOLORSCHEME' -> 16r2003.
			'CCM_GETUNICODEFORMAT' -> 16r2006.
			'CCM_GETVERSION' -> 16r2008.
			'CCM_SETBKCOLOR' -> 16r2001.
			'CCM_SETCOLORSCHEME' -> 16r2002.
			'CCM_SETUNICODEFORMAT' -> 16r2005.
			'CCM_SETVERSION' -> 16r2007.
			'CCM_SETWINDOWTHEME' -> 16r200B.
			'CCS_ADJUSTABLE' -> 16r20.
			'CCS_BOTTOM' -> 16r3.
			'CCS_LEFT' -> 16r81.
			'CCS_NODIVIDER' -> 16r40.
			'CCS_NOMOVEY' -> 16r2.
			'CCS_NOPARENTALIGN' -> 16r8.
			'CCS_NORESIZE' -> 16r4.
			'CCS_RIGHT' -> 16r83.
			'CCS_TOP' -> 16r1.
			'CCS_VERT' -> 16r80.
			'CDDS_ITEM' -> 16r10000.
			'CDDS_ITEMPOSTERASE' -> 16r10004.
			'CDDS_ITEMPOSTPAINT' -> 16r10002.
			'CDDS_ITEMPREERASE' -> 16r10003.
			'CDDS_ITEMPREPAINT' -> 16r10001.
			'CDDS_POSTERASE' -> 16r4.
			'CDDS_POSTPAINT' -> 16r2.
			'CDDS_PREERASE' -> 16r3.
			'CDDS_PREPAINT' -> 16r1.
			'CDDS_SUBITEM' -> 16r20000.
			'CDIS_CHECKED' -> 16r8.
			'CDIS_DEFAULT' -> 16r20.
			'CDIS_DISABLED' -> 16r4.
			'CDIS_DROPHILITED' -> 16r1000.
			'CDIS_FOCUS' -> 16r10.
			'CDIS_GRAYED' -> 16r2.
			'CDIS_HOT' -> 16r40.
			'CDIS_INDETERMINATE' -> 16r100.
			'CDIS_MARKED' -> 16r80.
			'CDIS_NEARHOT' -> 16r400.
			'CDIS_OTHERSIDEHOT' -> 16r800.
			'CDIS_SELECTED' -> 16r1.
			'CDIS_SHOWKEYBOARDCUES' -> 16r200.
			'CDRF_DODEFAULT' -> 16r0.
			'CDRF_DOERASE' -> 16r8.
			'CDRF_NEWFONT' -> 16r2.
			'CDRF_NOTIFYITEMDRAW' -> 16r20.
			'CDRF_NOTIFYPOSTERASE' -> 16r40.
			'CDRF_NOTIFYPOSTPAINT' -> 16r10.
			'CDRF_NOTIFYSUBITEMDRAW' -> 16r20.
			'CDRF_SKIPDEFAULT' -> 16r4.
			'CDRF_SKIPPOSTPAINT' -> 16r100.
			'GDT_ERROR' -> -16r1.
			'GDT_NONE' -> 16r1.
			'GDT_VALID' -> 16r0.
			'GDTR_MAX' -> 16r2.
			'GDTR_MIN' -> 16r1.
			'I_IMAGECALLBACK' -> -16r1.
			'I_IMAGENONE' -> -16r2.
			'ICC_ANIMATE_CLASS' -> 16r80.
			'ICC_BAR_CLASSES' -> 16r4.
			'ICC_COOL_CLASSES' -> 16r400.
			'ICC_DATE_CLASSES' -> 16r121.
			'ICC_HOTKEY_CLASS' -> 16r40.
			'ICC_INTERNET_CLASSES' -> 16r800.
			'ICC_LINK_CLASS' -> 16r8000.
			'ICC_LISTVIEW_CLASSES' -> 16r1.
			'ICC_NATIVEFNTCTL_CLASS' -> 16r2000.
			'ICC_PAGESCROLLER_CLASS' -> 16r1000.
			'ICC_PROGRESS_CLASS' -> 16r20.
			'ICC_STANDARD_CLASSES' -> 16r4000.
			'ICC_TAB_CLASSES' -> 16r8.
			'ICC_TREEVIEW_CLASSES' -> 16r2.
			'ICC_UPDOWN_CLASS' -> 16r10.
			'ICC_USEREX_CLASSES' -> 16r200.
			'ICC_WIN95_CLASSES' -> 16rFF.
			'ILC_COLOR' -> 16r0.
			'ILC_COLOR16' -> 16r10.
			'ILC_COLOR32' -> 16r20.
			'ILC_COLOR4' -> 16r4.
			'ILC_COLOR8' -> 16r8.
			'ILC_COLORDB' -> 16rFE.
			'ILC_MASK' -> 16r1.
			'ILC_PALETTE' -> 16r800.
			'ILD_ASYNC' -> 16r8000.
			'ILD_BLEND' -> 16rF00.
			'ILD_BLEND25' -> 16r2.
			'ILD_BLEND50' -> 16r4.
			'ILD_DPISCALE' -> 16r4000.
			'ILD_FOCUS' -> 16r4.
			'ILD_IMAGE' -> 16r20.
			'ILD_MASK' -> 16r10.
			'ILD_NORMAL' -> 16r0.
			'ILD_OVERLAYMASK' -> 16rF00.
			'ILD_PRESERVEALPHA' -> 16r1000.
			'ILD_ROP' -> 16r40.
			'ILD_SCALE' -> 16r2000.
			'ILD_SELECTED' -> 16r4.
			'ILD_TRANSPARENT' -> 16r1.
			'INFOTIPSIZE' -> 16r400.
			'LIM_LARGE' -> 16r1.
			'LIM_SMALL' -> 16r0.
			'LVM_GETEDITCONTROL' -> 16r1018.
			'NM_CHAR' -> -16r12.
			'NM_CLICK' -> -16r2.
			'NM_CUSTOMDRAW' -> -16rC.
			'NM_CUSTOMTEXT' -> -16r18.
			'NM_DBLCLK' -> -16r3.
			'NM_FIRST' -> 16r0.
			'NM_FONTCHANGED' -> -16r17.
			'NM_HOVER' -> -16rD.
			'NM_KEYDOWN' -> -16rF.
			'NM_KILLFOCUS' -> -16r8.
			'NM_LDOWN' -> -16r14.
			'NM_NCHITTEST' -> -16rE.
			'NM_OUTOFMEMORY' -> -16r1.
			'NM_RCLICK' -> -16r5.
			'NM_RDBLCLK' -> -16r6.
			'NM_RDOWN' -> -16r15.
			'NM_RELEASEDCAPTURE' -> -16r10.
			'NM_RETURN' -> -16r4.
			'NM_SETCURSOR' -> -16r11.
			'NM_SETFOCUS' -> -16r7.
			'NM_THEMECHANGED' -> -16r16.
			'NM_TOOLTIPSCREATED' -> -16r13.
			'TTF_IDISHWND' -> 16r1.
			'TTN_GETDISPINFOA' -> -16r208.
			'TTN_GETDISPINFOW' -> -16r212.
			'TVM_GETEDITCONTROL' -> 16r110F
		}!

OS.CommCtrlConstants guid: (Core.GUID fromString: '{13fdce7c-6ba4-4b0a-8ec8-90af54a7fbb1}')!

OS.CommCtrlConstants isNonInstantiable: true!

OS.CommCtrlConstants comment: ''!

!OS.CommCtrlConstants categoriesForClass!External-Data-Constants! !

