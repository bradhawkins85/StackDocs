# StackDocs
Alternative to Hudu/ITGlue based on BookStack

This is a work in progress and currently has limited functionality.

The initial script (Build BookStack Template.ps1) will create a Shelf based on the company name, and Books for various document categories, a template Chapter for an entry of each book type, and required pages in the chapters.

The script will then add the Books to the Company Shelf.

Permissions are set to block inherited permissions on the Shelf and Book level to keep the documents private, additional permissions can bee added as needed.

**** Adding Books to Shelves is currently broken, as it setting the permissions, there appears to have been an API change in BookStack that needs updating in this script.

Future work will include the ability to add pages to existing chapters, for example if all Backup books need a new field added the script will search for all matching chapters and add the extra page.
Expiries will also be added later to flag when documents need review, or if there are license expiry dates that are approaching.

Example of "Test Company" Shelf
![image](https://github.com/user-attachments/assets/cfb2b359-a930-4569-83e2-9d1be37d328b)

Example of "Test Backups" Book, Chapter and Pages
![image](https://github.com/user-attachments/assets/3cefb369-0806-44b5-996f-8a70ab8ede87)

In the script adjust $company and $companyslug as required for each client.

$company will be the name of the Shelf, $companyslug will be appended before each Book title.
The script will create the Shaelf based on the company name in $company and will not re-create if the shelf already exists. It will also check if the Books already exist and not re-create them but will create the template (or append additional pages to the template) if needed.
