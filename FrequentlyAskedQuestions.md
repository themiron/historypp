# Frequently Asked Questions #

Here is the FAQ for the History++ plugin.
<a href='Hidden comment: It"s small right now, but you can add your own questions, just press "Edit this page" button at the bottom.'></a>

<a href='Hidden comment: 
== Contents ==

[[PageOutline(3,,inline)]]
'></a>
### Plugin doesn't load ###

This happened in old miranda versions, don't know if it happens still, but sometimes when you try different history viewers, miranda will fail to enable History++ after it was disabled. It may use default history viewer or another one instead of History++. How to fix:

_Fast solution:_


&lt;BR&gt;


Rename historypp.dll to (for example) histpp.dll
and start miranda. At start select histpp.dll
as history plugin.


&lt;BR&gt;


Note: you will have to rename plugin every time
you update it. So we have here...

_Right solution:_


&lt;BR&gt;


Download and install DatabaseEditor plugin (read [here on how to edit database](HowToEditDatabase.md)), start miranda and open Database Editor from the main menu. In the Database Editor window browse to Miranda -> Current user -> PluginDisable and delete all records with then name historypp.dll (you might have several items, written in different cases). Restart miranda and select historypp.dll at start as history plugin.

### Plugin doesn't load with error about EurekaLog х.х.хх trial version expired ###

Full error message is "The "miranda32.exe" program is compiled with EurekaLog х.х.хх trial version.

&lt;BR&gt;


You can test this program for 30 days after its compilation. To buy the EurekaLog full version go to: url...".

&lt;BR&gt;




&lt;BR&gt;


This happened 30 days old history++ debug builds compiled with trial [EurekaLog](EurekaLog.md) add-in debug tool.


&lt;BR&gt;


Since 15.05.2007 we have Professional EurekaLog licence, so just download more recent either stable debug or alpha build. See [Download](Download.md).

### After installing History++, default history viewer is shown ###

Read question 1, "Plugin doesn't load". If it doesn't help, submit a [new issue](http://code.google.com/p/historypp/issues/entry).

### Help! I've lost password to my history! ###
If you've lost your password, do the following:
  1. Read [how to edit database](HowToEditDatabase.md)
  1. In DatabaseEditor navigate to Current user -> HistoryPlusPlus
  1. Delete record "Password"
Now your password is blank and you can open any
contact's history.

### Where to download the latest version? ###

See [Download](Download.md).

### Can I download version prior to 1.5 or 1.4? ###

Yes, see OlderVersions.

### How to change fonts and colors in history? ###

You need to install FontService plugin, see CustomizationSupport.

### How to change icons in History++? ###

You need to install IcoLib plugin, see CustomizationSupport.

### How to change text copied to clipboard? ###

To change/format text copied to clipboard see TextFormatting.

### How to change text quoted to **srmm message area? ###**

To change/format text quoted to **srmm message area see TextFormatting.**

### How can I export all history of all my contacts to files? ###

If you need to export ALL history automatically, you can download [Message Export](http://addons.miranda-im.org/details.php?action=viewfile&id=254) plugin or use [mContacts plugin](http://miranda.kom.pl/dev/bankrut/) ([mirror](http://www.dobranoc.net/bankrut/)).

### Can I import other histories? ###

No. But we are currently evaluating different possibilities. For now, you can use [mContacts plugin](http://miranda.kom.pl/dev/bankrut/) ([mirror](http://www.dobranoc.net/bankrut/)) for import/export.

### Can I make History++ remember the last filter? ###

Well, partially. In the Filter Customization dialog you can set any filter as the first and History++ will open every window with the first filter. So making any filter the first will make it "default".

There are no plans to save the last used filter per contact or on global basis. We believe that it will be more of a troublemaker, than lifesaver for most of the users.

### Can I hide the toolbar? ###

Yes, but it's a hack. First, read on [how to edit database settings](HowToEditDatabase.md). You have to create `HistoryToolbar` string setting if it doesn't exist already. If it exists, edit it and make it empty (delete all the contents (text) in the setting, but not the setting item itself!). If you create new one, leave it empty. The next time you open history window, toolbar will be hidden. To show it again, just delete `HistoryToolbar` setting (this time delete the whole setting itself, not its contents).

### Does History++ save history unless erased? ###

History++ does not keep history itself. Instead, Miranda IM manages history keeping. So, depending on the Miranda database driver, IM protocol or their settings, history keeping behavior can differ. In this sense, History++ is only an advanced history viewer, not responsible for actual history management. There are other plugins available for Miranda, that can auto-export or auto-delete history for you.

### Where History++ saves chat history? ###

History++ does not save history. Instead, database driver saves history (generally in miranda profile).

&lt;BR&gt;


See Also: [Article Directory](http://www.tonarticles.com), [Verizon Wireless - LG enV3 Touch](http://www.verizonenv.com), [Scripts and programming](http://www.egscript.info)