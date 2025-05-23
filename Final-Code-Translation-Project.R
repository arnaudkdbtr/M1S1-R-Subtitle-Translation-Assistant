#Subtitle Translation Assistant

rm(list = ls()) #Cleaning the working environment

#Checking if required packages are installed; if not, installing them
if (!require("httr")) install.packages("httr")
if (!require("stringr")) install.packages("stringr")
if (!require("stringi")) install.packages("stringi")
if (!require("jsonlite")) install.packages("jsonlite")
if (!require("shiny")) install.packages("shiny")
if (!require("rvest")) install.packages("rvest")
if (!require("dplyr")) install.packages("dplyr")
if (!require("readr")) install.packages("readr")

#Loading required packages
library(httr)
library(stringr)
library(jsonlite)
library(shiny)
library(rvest)
library(dplyr)
library(readr)
library(stringi)

api_key_deepl = "INSERT API KEY" #You have to create an account to get a new API Key

#Function to detect encoding with stringi
detect_encoding <- function(input_file) {
  content <- readBin(input_file, what = "raw", n = file.size(input_file))
  encodings <- stri_enc_detect(content)
  
  #Finding encoding with the most confidence
  encoding_info <- encodings[[1]]
  detected_encoding <- encoding_info$Encoding[which.max(encoding_info$Confidence)]
  
  return(detected_encoding)
}

#Function to search on OpenSubtitles and retrieve results
get_open_subtitles_results <- function(query) {
  url <- paste0("https://www.opensubtitles.org/fr/search2/moviename-", gsub(" ", "+", query), "/sublanguageid-all")
  page <- read_html(url)
  
  movie_names <- page %>% 
    html_nodes("a[class='bnone']") %>% 
    html_text() %>% 
    gsub("\n|\t", "", .)
  
  movie_links <- page %>% 
    html_nodes("a[class='bnone']") %>% 
    html_attr("href") %>% 
    paste0("https://www.opensubtitles.org", .)
  
  results <- data.frame(
    movie_name = movie_names,
    link = movie_links,
    stringsAsFactors = FALSE
  )
  
  return(results)
}

#Function to extract available subtitles for the user search query
get_subtitles <- function(movie_url) {
  page <- read_html(movie_url)
  
  subtitles <- page %>% 
    html_nodes("td[id^='main'] a[class='bnone']") %>% 
    html_attr("href")
  
  return(subtitles)
}

#Function to download and extract subtitles
download_subtitle <- function(download_url, dest_dir = "subtitles") {
  if (!dir.exists(dest_dir)) dir.create(dest_dir)
  
  #Create a temporary folder for this specific operation
  temp_dir <- tempfile(pattern = "subtitles_temp")
  dir.create(temp_dir)
  
  temp_file <- tempfile(fileext = ".zip")
  
  #Download zip file
  GET(download_url, write_disk(temp_file, overwrite = TRUE))
  
  #Extract file to temporary folder
  unzip(temp_file, exdir = temp_dir)
  
  #List only files in the temporary folder
  files <- list.files(temp_dir, recursive = TRUE, full.names = TRUE)
  
  #Filter .srt files and exclude unnecessary files
  nfo_files <- files[grepl("\\.nfo$", files, ignore.case = TRUE)]
  if (length(nfo_files) > 0) {
    file.remove(nfo_files)
  }
  
  srt_files <- files[grepl("\\.srt$", files, ignore.case = TRUE)]
  
  if (length(srt_files) > 0) {
    #Move .srt files to the subtitles folder
    moved_files <- file.copy(srt_files, dest_dir, overwrite = TRUE)
    
    #Clean temporary folder
    unlink(temp_dir, recursive = TRUE)
    unlink(temp_file)
    
    message("Subtitles downloaded and extracted in: ", dest_dir)
    
    #Return new .srt files only
    return(file.path(dest_dir, basename(srt_files[moved_files])))
  } else {
    #Clean even if you fail
    unlink(temp_dir, recursive = TRUE)
    unlink(temp_file)
    
    message("No .srt files found in the downloaded archive.")
    return(NULL)
  }
}

#Function to convert to UTF-8
convert_to_utf8 <- function(input_file, output_file) {
  #Encoding detection
  detected_encoding <- detect_encoding(input_file)
  message("Detected encoding : ", detected_encoding)
  
  #Play file with detected encoding
  content <- tryCatch(
    {
      readLines(input_file, encoding = detected_encoding, warn = FALSE)
    },
    error = function(e) {
      stop("Error reading file with detected encoding (", detected_encoding, "): ", e$message)
    }
  )
  
  #Converting to UTF-8
  output_file <- sub("\\.srt$", "_utf8.srt", input_file)
  tryCatch({
    utf8_content <- iconv(content, from = detected_encoding, to = "UTF-8", sub = "byte")
    writeLines(utf8_content, output_file, useBytes = TRUE)
    message("Conversion to UTF-8 successfully completed and saved: ", output_file)
    
    #Deleting the original file after conversion
    if (file.exists(input_file)) {
      file.remove(input_file)
      message("Original file deleted : ", input_file)
    }
    
    return(output_file)
  }, error = function(e) {
    stop("Error converting to UTF-8 : ", e$message)
  })
}

#List of languages supported by DeepL
languages_deepl = list(
  "Arabic" = "ar", "Bulgarian" = "bg", "Chinese (Simplified)" = "zh", 
  "Czech" = "cs", "Danish" = "da", "Dutch" = "nl", "English" = "en", 
  "Estonian" = "et", "Finnish" = "fi", "French" = "fr", "German" = "de", 
  "Greek" = "el", "Hungarian" = "hu", "Italian" = "it", "Japanese" = "ja", 
  "Korean" = "ko", "Latvian" = "lv", "Lithuanian" = "lt", "Polish" = "pl", 
  "Portuguese" = "pt", "Romanian" = "ro", "Russian" = "ru", "Slovak" = "sk", 
  "Slovenian" = "sl", "Spanish" = "es", "Swedish" = "sv", "Turkish" = "tr", 
  "Ukrainian" = "uk"
)

#List of languages supported by Google Translate
languages_google_translate = list(
  "Afrikaans" = "af", "Arabic" = "ar", "Basque" = "eu", "Bengali" = "bn", 
  "Catalan" = "ca", "Chinese (Simplified)" = "zh", "Czech" = "cs", 
  "Croatian" = "hr", "Danish" = "da", "Dutch" = "nl", "Finnish" = "fi", 
  "French" = "fr", "German" = "de", "Greek" = "el", "Guarani" = "gn", 
  "Hebrew" = "he", "Hindi" = "hi", "Hmong" = "hmn", "Icelandic" = "is", 
  "Italian" = "it", "Japanese" = "ja", "Kannada" = "kn", "Korean" = "ko", 
  "Kurdish" = "ku", "Latvian" = "lv", "Lithuanian" = "lt", "Malayalam" = "ml", 
  "Marathi" = "mr", "Mongolian" = "mn", "Nepali" = "ne", "Norwegian" = "no", 
  "Polish" = "pl", "Portuguese" = "pt", "Punjabi" = "pa", "Romanian" = "ro", 
  "Russian" = "ru", "Serbian" = "sr", "Slovak" = "sk", "Slovenian" = "sl", 
  "Spanish" = "es", "Swahili" = "sw", "Swedish" = "sv", "Tamil" = "ta", 
  "Telugu" = "te", "Thai" = "th", "Turkish" = "tr", "Ukrainian" = "uk", 
  "Vietnamese" = "vi", "Xhosa" = "xh", "Yiddish" = "yi", "Zulu" = "zu"
)

#Function for translation using DeepL
deepl_translation <- function(inputfile, language, api_key_deepl) {
  answer = POST(
    url = "https://api-free.deepl.com/v2/translate",
    body = list(
      auth_key = api_key_deepl,
      text = inputfile,
      target_lang = toupper(language)  #DeepL uses uppercase language code (ex : en => EN)
    ),
    encode = "form"
  )
  response_data = content(answer, "parsed", encoding = "UTF-8")
  
  #Check if the translation is available or not
  if (!is.null(response_data$translations) && length(response_data$translations) > 0) { #If the translation is not null and the length of the answer > 0 then return the response
    return(response_data$translations[[1]]$text)
  } else {                                                                              #If anything else happen => error
    message("(DeepL) Translation error or no translation available.")
    return(NULL)
  }
}

#Function for translation using Google Translate
google_translation <- function(inputfile, language) {
  url = paste0(
    "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=",
    language,
    "&dt=t&q=",
    URLencode(inputfile)
  )
  
  response = GET(url)
  response_data = content(response, "parsed", encoding = "UTF-8")
  
  if (!is.null(response_data) && length(response_data) > 0) {
    translated_text = sapply(response_data[[1]], function(x) x[[1]])
    return(paste(translated_text, collapse = " "))
  } else {
    message("(Google Translate) Translation error or no translation available.")
    return(NULL)
  }
}

#Function to process and translate a block of text
process_translation_block <- function(text_block, timing, language, service, api_key_deepl) {
  original_text = paste(text_block, collapse = "") # Merge all lines
  
  if (service == "deepl") {
    translated_text = deepl_translation(original_text, language, api_key_deepl)
  } else if (service == "google") {
    translated_text = google_translation(original_text, language)
  } else {
    stop("Invalid translation service specified. Use 'deepl', or 'google'.")
  }
  
  return(c(timing, paste(translated_text, "\n")))
}

translations <- function(inputfile, language, service) {
  lines = readLines(inputfile, encoding = "UTF-8")
  translated_lines = list()
  text_block = c()
  timing = NULL
  
  #Check file format (SRT or VTT)
  is_vtt = grepl("WEBVTT", lines[1])
  if (is_vtt) {
    lines = lines[-1] #Remove the "WEBVTT" line
  }
  
  for(line in lines){
    if (grepl("-->",line)){
      if(length(text_block)>0){
        original_text = paste(text_block, collapse ="")
        translated_text = deepl_translation(original_text, language, api_key_deepl)
        translated_lines = c(translated_lines, timing, paste(translated_text, "\n"))
        text_block = c() #To reset text_block and avoid translating multiple times the same thing
      }
      timing = line #Stock the timing line
    }
    else if (str_trim(line) %in% as.character(1:99999)){ #If the line corresponds to a subtitle number, then the number is stored to preserve the file structure.
      translated_lines = c(translated_lines,line)
    }
    
    else if (grepl("^NOTE", line)) {  #Note line detection
      #Add note line without translating
      translated_lines = c(translated_lines, line)
    }
    
    else if (grepl("^Slide [0-9]+", line)) {  #Detection of chapter titles such as “Slide 1”.
      #Add chapter title without translating
      translated_lines = c(translated_lines, line)
    } 
    
    else if(str_trim(line) != ""){ #If the line is not empty
      line_without_tag = gsub("</?[a-z]+>", "", str_trim(line)) #Remove HTML-like tags and the unnecessary spaces
      text_block = c(text_block, line_without_tag)
    }
    else{ #If the line is empty
      if(length(text_block)>0){ #If the text_block is not empty
        translated_lines = c(translated_lines, process_translation_block(text_block, timing, language, service, api_key_deepl))
        text_block = c() #Resetting text_block for the next text_block translation
      }
      translated_lines = c(translated_lines, line) #Adding the timing or number of the line to the translated_lines list
    }
  }
  
  if (length(text_block)>0){ #If there is a last block that is not followed by timing (at the end of the file)
    translated_lines = c(translated_lines, process_translation_block(text_block, timing, language, service, api_key_deepl))
  }
  
  translated_lines = unlist(translated_lines) #We transform the list into a single vector
  output_ext = if (is_vtt) ".vtt" else ".srt"
  outputfile = gsub("\\.(srt|vtt)$", paste0("_translated_", language, output_ext), inputfile)
  writeLines(translated_lines, outputfile, useBytes = TRUE)
  
  list(output = outputfile, preview = translated_lines)
}

main <- function() {
  #Step 1: Search, download and convert
  cat("Enter the name of a movie : ")
  query <- readline()
  
  results <- get_open_subtitles_results(query)
  
  if (nrow(results) == 0) {
    cat("No results found.\n")
    return(NULL)
  }
  
  cat("\nSearch results :\n")
  for (i in 1:nrow(results)) {
    cat(i, ": ", results$movie_name[i], ", URL : ", results$link[i], "\n", sep = "")
  }
  
  cat("\nChoose a number to display the corresponding subtitles : ")
  choice <- as.numeric(readline())
  
  if (!is.na(choice) && choice > 0 && choice <= nrow(results)) {
    selected_url <- results$link[choice]
    subtitles <- get_subtitles(selected_url)
    
    if (length(subtitles) > 0) {
      cat("\nAvailable subtitles :\n")
      for (i in seq_along(subtitles)) {
        subtitle_parts <- gsub("^/fr/subtitles/(\\d+)/(.*)-(\\w{2})$", "\\1 \\2 \\3", subtitles[i])
        subtitle_info <- strsplit(subtitle_parts, " ")[[1]]
        id <- subtitle_info[1]
        title <- subtitle_info[2]
        language <- subtitle_info[3]
        complete_url <- paste0("https://www.opensubtitles.org/fr/subtitleserve/sub/", id)
        cat(i, ": ", title, " Language : ", language, " URL : ", complete_url, "\n", sep = "")
      }
      
      cat("\nSelect a number to download the corresponding subtitles: ")
      sub_choice <- as.numeric(readline())
      
      if (!is.na(sub_choice) && sub_choice > 0 && sub_choice <= length(subtitles)) {
        subtitle_parts <- gsub("^/fr/subtitles/(\\d+)/(.*)-(\\w{2})$", "\\1", subtitles[sub_choice])
        download_url <- paste0("https://www.opensubtitles.org/fr/subtitleserve/sub/", subtitle_parts)
        srt_files <- download_subtitle(download_url)
        
        if (!is.null(srt_files)) {
          last_file <- tail(srt_files, n = 1)  #Work only on the last file downloaded
          output_file <- sub("\\.srt$", "_utf8.srt", last_file)
          
          final_file <- convert_to_utf8(last_file, output_file)
          
          #Step 2: Launch Shiny UI with the downloaded file
          cat("Download and conversion complete. Launching translation interface...\n")
          
          #Shiny User Interface
          ui <- fluidPage(
            titlePanel("Subtitle Translator"),
            sidebarLayout(
              sidebarPanel(
                fileInput("fileInput", "Change Current file uploaded (SRT or VTT)", accept = c(".srt", ".vtt")),
                verbatimTextOutput("defaultFileInfo"),  # Display information about the default file
                radioButtons("service", "Translation Service", 
                             choices = list("DeepL" = "deepl", "Google Translate" = "google"), 
                             selected = "deepl"),  # Default service
                uiOutput("languageUI"), # Dynamic language selector
                actionButton("translate", "Translate"),
                downloadButton("download", "Download Translated Subtitles")
              ),
              mainPanel(
                h3("Preview of Translated Subtitles"),
                verbatimTextOutput("preview"),
                h4("Translation Duration"),
                verbatimTextOutput("duration")  # Output for translation duration
              )
            )
          )
          
          server <- function(input, output, session) {
            translation_duration = reactiveVal(NULL)  # Reactive value to store duration
            default_file_path <- final_file
            temp_file_path <- tempfile(fileext = ".srt")
            
            # Copy the default file to a temporary path at startup
            if (file.exists(default_file_path)) {
              file.copy(default_file_path, temp_file_path)
            }
            
            #Reactive value to store the currently selected file
            current_file <- reactiveVal(temp_file_path)
            
            observe({
              req(input$fileInput)
              #Update the current file when a new file is uploaded
              current_file(input$fileInput$datapath)
            })
            
            output$defaultFileInfo <- renderText({
              if (is.null(input$fileInput)) {
                paste("Current file uploaded :", basename(default_file_path))
              } else {
                paste("Uploaded file:", basename(input$fileInput$name))
              }
            })
            
            output$languageUI = renderUI({
              req(input$service)
              if (input$service == "deepl") {
                selectInput("language", "Target Language", choices = languages_deepl)
              } else {
                selectInput("language", "Target Language", choices = languages_google_translate)
              }
            })
            
            translation_result = reactiveVal(NULL)
            
            observeEvent(input$translate, {
              req(current_file(), input$language, input$service)
              start_time = Sys.time()  #Start the timer
              
              translation = translations(current_file(), input$language, input$service)
              translation_result(translation)
              
              end_time = Sys.time()  #End the timer
              translation_duration(difftime(end_time, start_time, units = "secs"))  #Calculate the Translation duration
            })
            
            output$preview = renderText({
              req(translation_result())
              paste(translation_result()$preview, collapse = "\n")
            })
            
            output$duration = renderText({
              req(translation_duration())
              paste("Translation completed in:", translation_duration(), "seconds")
            })
            
            output$download = downloadHandler(
              filename = function() {
                basename(translation_result()$output)
              },
              content = function(file) {
                file.copy(translation_result()$output, file)
              }
            )
          }
          
          #Run Shiny app
          shinyApp(ui = ui, server = server)
          
        } else {
          cat("No files downloaded.\n")
        }
      } else {
        cat("Invalid choice. Program Completed\n")
      }
    } else {
      cat("No subtitles found for this film.\n")
    }
  } else {
    cat("Invalid choice. Program Completed\n")
  }
}

#Run the Subtitle Translation Assistant
main()
