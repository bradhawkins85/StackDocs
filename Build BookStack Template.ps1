
$company = "Test Company"
$companyslug = "Test"

$company = "Test Company 2"
$companyslug = "Test2"

$company = "Test Company 3"
$companyslug = "Test3 "


$bookstackapikey = "your api key here"
$url = "https://yourbookstackurl/api"
$global:shelfid = ""
$global:bookid = ""
$global:chapterid = ""
$global:pagebody = ""

$global:shelves = ""
$global:books = ""
$global:chapters = ""
$global:pages = ""


$global:booklist = ""


$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Token $bookstackapikey")
$headers.Add("Content-Type", "application/json")
$headers.Add("Accept", "application/json")

Function GetListOfShelves() {
#get paginated list of shelves
$a = 0
$shelves = @("")
$mypages = @("")
$entry = ""
$results = [System.Collections.ArrayList]@()
do {
    $response = Invoke-RestMethod "$url/shelves?offset=$a" -Method 'Get' -Headers $headers

    $a += 100

    foreach ($shelf in $response.data) {
        $shelves += $shelf
    }

} until ($a -gt $response.total)

$global:shelves = $shelves
}

Function GetListOfBooks() {
    #Get existing shelves
    #get paginated list of books
        $a = 0
        $books = @("")
        $mypages = @("")
        $entry = ""
        $results = [System.Collections.ArrayList]@()
        do {
            $response = Invoke-RestMethod "$url/books?offset=$a" -Method 'Get' -Headers $headers

            $a += 100

            foreach ($book in $response.data) {
                $books += $book
            }

        } until ($a -gt $response.total)

        $global:books = $books
}

Function GetListOfChapters() {
    #Get existing shelves
    #get paginated list of books
        $a = 0
        $chapters = @("")
        $entry = ""
        $results = [System.Collections.ArrayList]@()
        do {
            $response = Invoke-RestMethod "$url/chapters?offset=$a" -Method 'Get' -Headers $headers

            $a += 100

            foreach ($chapter in $response.data) {
                $chapters += $chapter
            }

        } until ($a -gt $response.total)

        $global:chapters = $chapters
}

Function GetListOfPages() {
    #get paginated list of pages
    $a = 0
    $pages = @("")
    $mypages = @("")
    $entry = ""
    $results = [System.Collections.ArrayList]@()
    do {
        $response = Invoke-RestMethod "$url/pages?offset=$a" -Method 'Get' -Headers $headers

        $a += 100

        foreach ($page in $response.data) {
            $pages += $page
        }

    } until ($a -gt $response.total)
    $global:pages = $pages
}

Function GetShelf(){
    #Get existing shelves
    #$response = Invoke-RestMethod "$url/shelves" -Method 'Get' -Headers $headers #-Body $body
    
    GetListOfShelves
    $response = $global:shelves
    

    if ($response -match $company) {
        Write-Output "Shelf already exists"
        foreach ($item in $response.data) {
            if ($item.name -eq $company) {
                $global:shelfid = $item.id
            }
        }
    } else {
        Write-Output "Shelf does not exist creating shelf"
        CreateShelf
    }
}

Function CreateShelf(){
    $body.Add("name", "$company")
    $body = $body | ConvertTo-Json

    #Create shelf
    $response = Invoke-RestMethod "$url/shelves" -Method 'POST' -Headers $headers -Body $body
    $body.clear

    GetListOfShelves
    $response = $global:shelves

    foreach ($item in $response) {
        if ($item.name -eq $company) {
            $global:shelfid = $item.id
        }
    }
    Write-output "Created shelf id: $global:shelfid"

}

Function SetShelfPermissions() {
    #/content-permissions/{contentType}/{contentId}
    $response = Invoke-RestMethod "$url/content-permissions/bookshelf/$global:shelfid" -Method 'Get' -Headers $headers #-Body $body
    $response = $response | ConvertTo-Json

$body = @"
{
  `"owner_id`": 1,
  `"role_permissions`": [],
  `"fallback_permissions`": {
    `"inheriting`": false,
    `"view`": false,
    `"create`": false,
    `"update`": false,
    `"delete`": false
  }
}
"@

    $result = Invoke-RestMethod "$url/content-permissions/bookshelf/$global:shelfid" -Method 'PUT' -Headers $headers -Body $body


}

Function GetBook($bookname){
    GetListOfBooks
    $response = $global:books

    $booktitle = $companyslug + " " + $bookname
    #write-output $booktitle
    if ($response -match $booktitle) {

        foreach ($item in $response) {
            if ($item.name -eq "$booktitle") {
                $global:bookid = $item.id
            }
        }
        Write-Output "Book $booktitle ($global:bookid) already exists"
        if ($global:booklist -eq "") {$global:booklist += "$global:bookid"} else {$global:booklist += ",$global:bookid"}
        SetBookPermissions "$global:bookid"
    } else {
        Write-Output "Book $booktitle does not exist creating book"
        CreateBook "$booktitle"
    }
}

Function CreateBook($booktitle){
    $body = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $body.Add("name", "$booktitle")
    $body = $body | ConvertTo-Json

    #Create book
    $response = Invoke-RestMethod "$url/books" -Method 'POST' -Headers $headers -Body $body
    
    $body.clear
    #Get book details
    GetListOfBooks
    $response = $global:books
    foreach ($item in $response) {
        if ($item.name -eq $booktitle) {
            write-output $global:bookid
            $global:bookid = $item.id
            write-output $global:bookid
        }
    }

    Write-output "Created book id: $global:bookid"
    if ($global:booklist -eq "") {$global:booklist += "$global:bookid"} else {$global:booklist += ",$global:bookid"}
    SetBookPermissions "$global:bookid"
    

}

Function SetBookPermissions($bookid) {
    #/content-permissions/{contentType}/{contentId}
    #$response = Invoke-RestMethod "$url/content-permissions/book/$global:bookid" -Method 'Get' -Headers $headers #-Body $body
    #$response = $response | ConvertTo-Json

$body1 = @"
{
  `"owner_id`": 1,
  `"role_permissions`": [],
  `"fallback_permissions`": {
    `"inheriting`": false,
    `"view`": false,
    `"create`": false,
    `"update`": false,
    `"delete`": false
  }
}
"@

    $result = Invoke-RestMethod "$url/content-permissions/book/$bookid" -Method 'PUT' -Headers $headers -Body $body1


}

Function GetChapter($chapterName) {
    #Get existing shelves
    #$response = Invoke-RestMethod "$url/chapters" -Method 'Get' -Headers $headers #-Body $body

    GetListOfChapters
    $response = $global:chapters

    $chapterTitle = "$companyslug $chapterName Template"
    if ($response -match $chapterTitle) {
        Write-Output "Chapter $chapterTitle ($global:chapterid) already exists"
        foreach ($item in $response) {
            if ($item.name -eq $chapterTitle) {
                $global:chapterid = $item.id
                $global:bookid = $item.book_id
            }
        }
    } else {
        Write-Output "Chapter does not exist creating chapter"
        CreateChapter "$chapterName"
    }
}

Function CreateChapter($chapterName) {

    GetListOfBooks
    $response = $global:books

    #$response = $response | ConvertTo-Json
    $booktitle = $companyslug + " " + $chapterName
    #write-output $booktitle
    if ($response -match $booktitle) {

        foreach ($item in $response) {
            if ($item.name -eq "$booktitle") {
                $global:bookid = $item.id
            }
        }
    }


$chapterbody = @"
{
	`"book_id`": `"$global:bookid`",
	`"name`": `"$companyslug $chapterName Template`",
"@


$chaptertags = @"

`"tags`": [
{`"name`": `"Template`", `"value`": `"$chapterName`"}
]
}
"@



$body = $chapterbody + $chaptertags





    $response = Invoke-RestMethod "$url/chapters" -Method 'POST' -Headers $headers -Body $body
    #$body.clear



    GetListOfChapters
    $response = $global:chapters

    foreach ($item in $response) {
        if ($item.name -eq "$companyslug $chapterName Template") {
            $global:chapterid = $item.id
            $global:bookid = $item.book_id
        }
    }
    Write-output "Created chapter id: $global:chapterid"

}



Function GetPage($chapterName) {
#Find template chapter for named chapter
    GetListOfChapters
    $response = $global:chapters

    ### There is an issue here somewhere, not finding existing pages ####

    #$response.data.count
    $chapterTitle = "$companyslug $chapterName Template"
    if ($response -match $chapterTitle) {
        #Write-Output "Chapter $chapterTitle already exists"
        foreach ($item in $response.data) {
            if ($item.name -eq $chapterTitle) {
                $global:chapterid = $item.id
                $global:bookid = $item.book_id
            }
        }
        #write-output "$global:chapterid / $global:bookid"
    }
    
    GetListOfPages
    $pages = $global:pages

    $mypages = @("")
    foreach ($entry in $pages) {
        if ($entry.chapter_id -eq $global:chapterid) {
            $mypages += $entry
        }
    }


$global:pagebody1 = @"
{
	`"book_id`": `"$global:bookid`",
	`"chapter_id`": `"$global:chapterid`",
	`"html`": `"<p></p>`",
"@


if ($chapterName -eq "Applications") {
    $pagelist = @("Product Key", "Application Type", "Version", "Application Champion")
}  

if ($chapterName -eq "Backups") {
    $pagelist = @("Backup Program","Backup Source","Backup Type","Backup Schedule","Encryption Key","Backup Destination","Off-Site Backup Destination","Off-Site Backup Encryption Key","Notes")
} 

if ($chapterName -eq "Domains") {
    $pagelist = @("Hosting Provider","Hosting Provider Username","Hosting Provider Password","Email Provider","Email Provider Username","Email Provider Password","DNS Provider","DNS Provider Username","DNS Provider Password")
}

if ($chapterName -eq "Networks") {
    $pagelist = @("Subnet Mask","Gateway","DNS 1","DNS 2","DHCP Server","DHCP Options","Range Start","Range End","Exclusions","Static Mappings")
}

if ($chapterName -eq "NVR") {
    $pagelist = @("IP Address","Brand / Model","Username","Password","Supplier","Photo","Switch and Port")
}

if ($chapterName -eq "Phone") {
    $pagelist = @("Brand / Model","IP Address","Username","Password","Supplier","Photo","VOIP Provider","VOIP Provider Username","VOIP Provider Password","SIP Trunk Details","Switch and Port")
}

if ($chapterName -eq "Printers") {
    $pagelist = @("Make/Model","IP Address","Username","Password","Deployment","Notes","Photo","Driver Link","Switch and Port")
}

if ($chapterName -eq "Processes") {
    $pagelist = @("")
}

if ($chapterName -eq "Racks") {
    $pagelist = @("RU#")
}

if ($chapterName -eq "Shared Folders") {
    $pagelist = @("User")
}

if ($chapterName -eq "Switch Ports") {
    $pagelist = @("Port#")
}

if ($chapterName -eq "Wireless Networks") {
    $pagelist = @("Password","Encryption","VLAN","APs")
}

if ($chapterName -eq "Wireless Access Points") {
    $pagelist = @("IP Address","Manufacturer","Username","Password","Photo")
}

if ($chapterName -eq "BitLocker Keys") {
    $pagelist = @("Drive Letter and Encryption Key")
}

if ($chapterName -eq "User Passwords") {
    $pagelist = @("Username","Password","URL")
}

if ($chapterName -eq "Switches") {
    $pagelist = @("IP Address","Username","Password","Serial Number","Manufacturer","Model","Photo")
}

if ($chapterName -eq "NAS") {
    $pagelist = @("IP Address","Username","Password","Manufacturer","Model","Serial Number","Photo")
}

if ($chapterName -eq "Routers") {
    $pagelist = @("IP Address","Username","Password","Manufacturer","Serial Number","Route Map","Photo")
}

if ($chapterName -eq "Misc Network Devices") {
    $pagelist = @("IP Address","Username","Password","Notes","Photo","Related Device / Service / App")
}





$existingpages = @("")
foreach ($page in $mypages) {
    $existingpages += $page.name
}

foreach ($page in $pagelist) {
    if ($existingpages -notcontains $page) {
        write-output "Creating page $page"
        CreatePage "$page" "$chapterName"
    }
}

 
        
}

Function CreatePage($pagename, $chapterName) {
    #$global:pagetags.add("Template", "$chapterName")

    #$global:pagebody.Add("name", "$pagename")

$global:pagebody2 = @"

	`"name`": `"$pagename`",
"@
    

$pagetags = @"

    `"tags`": [
	{`"name`": `"Template`", `"value`": `"$chapterName`"}
]
}
"@
    
    $thispagebody = $global:pagebody1 + $global:pagebody2 + $pagetags

    $response = Invoke-RestMethod "$url/pages" -Method 'POST' -Headers $headers -Body $thispagebody  #($global:pagebody | convertto-json)
#    $global:pagebody.Remove("name")
#   $global:pagebody.Remove("tags")
}

Function AddBookToShelf() {

$body = @"
{
  `"name`": "$company",
  `"books`": [$global:booklist]
}
"@
$result = Invoke-RestMethod "$url/shelves/$global:shelfid" -Method 'PUT' -Headers $headers -Body $body

}

GetShelf
SetShelfPermissions
GetBook "KB"


GetBook "Applications"
GetChapter "Applications"
GetPage "Applications"


GetBook "Backups"
GetChapter "Backups"
GetPage "Backups"


GetBook "Domains"
GetChapter "Domains"
GetPage "Domains"

GetBook "Networks"
GetChapter "Networks"
GetPage "Networks"

GetBook "NVR"
GetChapter "NVR"
GetPage "NVR"

GetBook "Phone"
GetChapter "Phone"
GetPage "Phone"

GetBook "Printers"
GetChapter "Printers"
GetPage "Printers"

GetBook "Processes"

GetBook "Racks"
GetChapter "Racks"
GetPage "Racks"

GetBook "Shared Folders"
GetChapter "Shared Folders"
GetPage "Shared Folders"

GetBook "Switch Ports"
GetChapter "Switch Ports"
GetPage "Switch Ports"

GetBook "Wireless Networks"
GetChapter "Wireless Networks"
GetPage "Wireless Networks"

GetBook "Wireless Access Points"
GetChapter "Wireless Access Points"
GetPage "Wireless Access Points"

GetBook "BitLocker Keys"
GetChapter "BitLocker Keys"
GetPage "BitLocker Keys"

GetBook "User Passwords"
GetChapter "User Passwords"
GetPage "User Passwords"

GetBook "Switches"
GetChapter "Switches"
GetPage "Switches"

GetBook "NAS"
GetChapter "NAS"
GetPage "NAS"

GetBook "Routers"
GetChapter "Routers"
GetPage "Routers"

GetBook "Misc Network Devices"
GetChapter "Misc Network Devices"
GetPage "Misc Network Devices"

GetBook "Network Diagrams"
GetChapter "Network Diagrams"
GetPage "Network Diagrams"



#SetChapterPermissions

#SetPagePermissions

AddBookToShelf
