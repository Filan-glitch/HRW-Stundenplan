package de.janbellenberg.timetable

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class DatabaseHelper(private val context: Context) : SQLiteOpenHelper(
    context,
    context.filesDir.parent?.plus("/databases/timetable.db"), null, 3
) {
    override fun onCreate(db: SQLiteDatabase?) {
        db?.execSQL("CREATE TABLE IF NOT EXISTS Grades (Identifier TEXT PRIMARY KEY, Title TEXT NOT NULL, Grade REAL, Credits_All INTEGER NOT NULL, Credits_Charged INTEGER, Status TEXT NOT NULL)")
        db?.execSQL("CREATE TABLE IF NOT EXISTS Events (EventID TEXT PRIMARY KEY, Title TEXT NOT NULL, Abbreviation TEXT, Start TEXT, End TEXT, Room TEXT, WeekFrom TEXT NOT NULL, Weekday TEXT NOT NULL, HIDE_FLAG INTEGER NOT NULL DEFAULT 0, MODE INTEGER NOT NULL DEFAULT 0)")
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        if (oldVersion <= 1) db?.execSQL("ALTER TABLE Events ADD COLUMN HIDE_FLAG INTEGER NOT NULL DEFAULT 0")
        if (oldVersion <= 2) db?.execSQL("ALTER TABLE Events ADD COLUMN MODE INTEGER NOT NULL DEFAULT 0")
    }

    fun queryEvents(date: String, weekday: String): MutableList<Event> {
        val db = this.readableDatabase
        val cursor = db.rawQuery(
            "SELECT * FROM Events WHERE WeekFrom = ? AND Weekday = ? AND HIDE_FLAG = 0",
            arrayOf(date, weekday)
        )
        val returnList: MutableList<Event> = ArrayList()
        while (cursor.moveToNext()) {
            returnList.add(
                Event(
                    cursor.getString(cursor.getColumnIndexOrThrow("Title")),
                    cursor.getString(cursor.getColumnIndexOrThrow("Abbreviation")),
                    cursor.getString(cursor.getColumnIndexOrThrow("Start")),
                    cursor.getString(cursor.getColumnIndexOrThrow("End")),
                    cursor.getString(cursor.getColumnIndexOrThrow("Room"))
                ))
        }

        cursor.close()
        db.close()
        return returnList
    }
}
