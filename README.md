# Comparison between old and new battle systems
These are a handful of files for the turn-based RPG battle system I’m working on in my free time.  Between my summer internship and school, I didn’t have much time to work on this project.  So, once I was able to work on it, I could not remember how the battle system worked.  After hours of looking through my code I remembered how it worked and saw how I could improve upon it.  Here is a quick list of things that got changed…

- All updated files are using static typing.
   - This increases performance overall.
- The ATB code got moved out of the characters code and into the battle code.
   - It didn’t make sense to have in the characters code since it is only needed during battles.
-	Damage calculations are handled in the battle code not characters code.
      - Like above it didn’t make sense to have it in the characters and enemies’ code.
-	The enemy and player characters inherit from one base class for stats.
      - This made it so code was standardized between classes simplifying the battle system code.
- Simplified players input code during battle.
- Simplified battle system code.
   - In the old file since the characters and enemies had different base classes I had to have code that handled each one differently.  Now with the standardized base class with overridable functions made it each character can be handled the same.  Example being  
    for the attack stat the player character adds in equipped weapon attack stat.  While the enemy uses the base function that returns its attack stat only.
- This might be the biggest one is I commented by code and started creating documentation.
  - So, the hours of figuring out my code doesn’t happen again.
