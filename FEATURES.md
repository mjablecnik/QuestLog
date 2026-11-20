# Questlog — Features

The full list of what the app does. For a short overview see [README.md](./README.md); for
internals see [DOCS.md](./DOCS.md).

Questlog is a personal gamified to-do app for one user, built with Flutter for iOS first
(the Linux desktop build is used for development and tests).

- **Quests** are one-off tasks with an effort tier (moment, hour, part of a day, full day; 10, 25, 50 or
  100 XP) chosen by how much time they take, which decides the XP they award; the Board has two sections, Today (what you want to focus on) and Todo (where every new quest lands); you reorder quests by dragging and move them between the sections the same way.
- **Missions** are long-term goals made of quests, with a progress ring and a bonus XP
  reward (small, medium, large) when the last quest is done. Missions can be reordered by
  dragging. Their quests live in the mission and reach the Board only when you post them
  there (Today or Todo) from the quest's edit sheet.
- **Deadline**: a Quest can have a date. It then shows in the Calendar as an event you can edit or delete without touching the Quest, and an open Quest past its date is marked Overdue.
- **XP and levels** are shown in the hero bar; completing a quest or mission opens a reward
  card, and reopening one takes the XP back.
- **Calendar** is a tab with a month overview, a day sheet, event detail, an event form,
  search and a type filter. Events have one of eleven types, each with its own colour (quest deadline, dance, work,
  birthday, name day, public holiday, notable day, date, meeting, seminar, lesson) and may repeat
  daily, weekly, monthly or yearly. The first start fills it with the Czech public holidays,
  notable and folk days and a few name days, repeating every year. An event with the "On the
  board" switch shows up on the Board on its day as a task: completing it earns 10 to 100 XP
  (by the event's length, or by its type for an all-day event). The address field suggests addresses from earlier events and forgets those unused for 30 days. An event of several days is drawn as one
  bar across its days in the month view.
- **Notes** are a fifth tab: Folders and sub-Folders of any depth hold Notes, which you write in a WYSIWYG editor
  (Markdown underneath: headings, bold, italic, code, links, lists, checklists, quotes) that saves by itself.
  A Note has a title field above its text; left empty, the name follows the first line.
  Folders and Notes can be renamed, moved to another Folder and deleted; deleting moves them to a Trash
  (the bin icon at the top level) where they stay for 30 days and can be restored or deleted for good;
  a trashed Note can be opened to read before deciding.
- **Recurring missions** are posted automatically from rules set up in Settings (daily,
  weekly, biweekly, monthly, quarterly or yearly).
- **Two looks and two languages**: a dark and a light theme of the blue palette
  (or follow the system), in Czech or English. One typeface, Figtree, for text and titles.
- **Licences**: the bundled font is under the SIL Open Font License; its text ships in
  `assets/fonts/licenses/` and are listed under Settings → About → Licenses.
- **Data export**: Settings → Data → Export data saves everything into one JSON file and opens the share sheet (see DOCS.md).
- **Local only**: data lives in a SQLite file on the device through Drift. There is no
  server, no account and no network access.

A link such as `questlog://calendar` opens a tab, so a Shortcuts icon on the Home Screen can open the app on the Calendar (see DOCS.md).

The board day rolls over at 04:00, so a late evening still belongs to the same day.
