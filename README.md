# Gradify: Image-Based Examination Grade Checker with Web Monitoring
Gradify is a mobile application designed to help teachers efficiently check students' periodical exam scores by scanning bubble answer sheets. The app uses image recognition and machine learning technologies to accurately extract and display scores, providing a fast and reliable grading solution. Additionally, Gradify includes a web-based monitoring system for teachers and administrators to manage and track student grades, as well as review detailed item analysis to improve educational outcomes. Students can also easily track their periodical exam grades by accessing their Gradify accounts on the web.

## Features

### Mobile App (Teacher-Focused)
- Bubble Sheet Scanning: Scan bubble answer sheets and automatically extract student scores.
- Fast and Accurate Results: Leverage image processing libraries for quick, accurate grading of multiple-choice exams.
- User-Friendly Interface: Simple, intuitive design that makes grading faster and easier for teachers.
- Secure Data Handling: Grades and student data are securely stored and managed.
- Real-Time Score Display: View instant feedback and results after scanning an answer sheet.

### Web Dashboard (Teacher/Administrator-Focused)
- Grade Tracking: Monitor and manage student exam scores over time.
- Item Analysis: Review item-level performance to identify trends, common mistakes, and areas for improvement.
- Student Performance Reports: Generate reports showing overall class performance and individual student progress.
- Data Export: Export grades and reports in CSV or Excel formats for further analysis or record-keeping.
- Role-Based Access: Manage access levels for teachers, administrators, and other users with roles and permissions.

### Web Dashboard (Student-Focused)
- Grade Tracking for Students: Students can log in to view their periodical exam scores.
- Performance Overview: Students can see detailed performance data, including item-level analysis and comparison to class averages.
- Secure Access: Students can only access their own grades securely via their accounts.

## Technologies Used
**Mobile App:**
- Flutter
- OpenCV

**Website:**
- Ruby on Rails
- Tailwind CSS
- DaisyUI
- Stimulus JS

**Databases:**
- posgresql
- sqlite

## Installation


Clone the repository:
```
git clone https://github.com/eielelle/gradify-web.git
```

Install dependencies:
```
bundle install
npm install
```

Run development server:
```
./bin/dev
```

## Acknowledgements
- Thanks to teachers and the beneficiaries of this project for their valuable feedback and support.

- Special thanks to OpenCV for providing powerful open-source computer vision tools that help enable the image recognition capabilities in Gradify.