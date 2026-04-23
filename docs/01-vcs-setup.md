# Studio 5000 DevOps – VCS Setup Guide

## Who This Is For

This guide is intended for early adopters who want to explore version control workflows with Studio 5000 projects.

This is not a polished or fully integrated solution. It demonstrates what is possible using the Logix Designer SDK and structured project exports.

Some features (such as diff viewing and restore) rely on external tools or manual workflows.

> The example paths shown below are from the author's local setup. Replace them with the paths on your system.

> Example (author’s local environment): C:\Users\DevOps\Desktop\InstantFizz

> Use placeholders like "Path to your..." in commands, then refer to the example.

---

## 1. Install .NET 8 SDK

Go to: [https://dotnet.microsoft.com/download/dotnet/8.0](https://dotnet.microsoft.com/download/dotnet/8.0)

Download .NET SDK (Windows x64)

Install with defaults

Open PowerShell and run:

```
dotnet --version
```

---

## 2. Install Git

Go to: [https://git-scm.com/download/win](https://git-scm.com/download/win)

Download and install

Open new PowerShell and run:

```
git --version
```

---

## 3. Download VCS Tools Repository

### Option A (Git)

```
git clone https://github.com/RockwellAutomation/ra-logix-designer-vcs-custom-tools.git
cd ra-logix-designer-vcs-custom-tools
```

### Option B (Manual)

* Download ZIP from GitHub
* Extract to local folder
* Open PowerShell in that folder

---

## 4. Build Tools

```
cd ra-logix-designer-vcs-custom-tools
dotnet build -c Release
```

Wait for "Build succeeded"

Output:

```
artifacts\bin\Release
```

---

## 5. Navigate to Build Output

### PowerShell

```
cd .\artifacts\bin\Release
dir
```

### File Explorer

Navigate to:

```
artifacts → bin → Release
```

---

## 6. Verify Tool

```
.\l5xgit.exe -h
```

or

```
dotnet .\l5xgit.dll -h
```

> Note: `.\` means "run this program from the current folder".

---

## 7. Install Custom Tools in Studio 5000

The file is created during the build step.

The `artifacts` folder is generated automatically after running:

```
dotnet build
```

Path to your file:

```
Path to your cloned repo\artifacts\bin\Release\Assets\CustomToolsMenu.xml
```

Example:

```
C:\Users\DevOps\ra-logix-designer-vcs-custom-tools\artifacts\bin\Release\Assets\CustomToolsMenu.xml
```

Copy the file and paste into:

```
C:\Program Files (x86)\Rockwell Software\RSLogix 5000\Common\
```

Restart Studio 5000

---

## 8. Proposed Folder Structure

```
boiler-devops-demo/
  01-vcs/
    acd-source/
      BoilerDemo.ACD

    l5x-source/

    exploded-content/
      RSLogix5000Content/
        AddOnInstructionDefinitions/
        DataTypes/
        Modules/
        Programs/
        Tags/
        Tasks/
        RSLogix5000Content.xml
        export-options.yaml

    build/

    examples/
```

**Purpose**

* acd-source = original ACD files used for the demo
* l5x-source = L5X files
* exploded-content = exploded files (used for Git)
* build = manually rebuilt output for validation or learning
* examples = optional reference examples for the VCS workflow

---

### What is RSLogix5000Content

The `RSLogix5000Content` folder contains the exploded project data.

Each subfolder represents a part of the controller project:

* Programs → routines and logic
* Tags → controller and program tags
* Tasks → task configuration
* DataTypes → user-defined types
* Modules → I/O and hardware configuration
* AddOnInstructionDefinitions → AOIs

The files:

* RSLogix5000Content.xml → project structure and references
* export-options.yaml → export configuration used by the tool

> This folder structure is what Git tracks and compares between commits.

---

## 9. Initialize Git Repository

```
cd Path to your project folder
git init
```

---

## 10. Create a Commit (Two Workflows)

Both workflows result in:

* structured files created
* commit stored in Git

---

### 🔹 Workflow 1 — Studio 5000 (Automated)

#### Steps

1. Open ACD in Studio 5000
2. Go to:

```
Tools → Commit
```

3. When prompted for directory:

```
Path to your structured folder
```

Example:

```
C:\Users\DevOps\Desktop\boiler-devops-demo\01-vcs\exploded-content
```

4. You may then be asked:

```
Would you like to be prompted for a commit message for each commit? (y/n)
```

Enter:

```
y
```

5. Enter commit message:

```
initial commit
```

Press Enter twice

---

#### What Happens Behind the Scenes

```
ACD → L5X → explode → git add → git commit
```

---

#### Result

* `.yml` file created next to ACD
* exploded-content folder created/updated

```
exploded-content/
  RSLogix5000Content/
```
You have now:
- converted the project to a text-based format
- broken it into files
- created your first version in Git
---

### 🔹 Workflow 2 — PowerShell (Manual)

> Run these commands from:
>
> Path to your cloned repo\artifacts\bin\Release

This workflow shows the same steps performed manually for better understanding and automation.

#### Step 1 — Convert (ACD → L5X)

Converts the Studio 5000 project into an L5X file.

```
.\l5xgit.exe acd2l5x `
  --acd "Path to your .ACD file" `
  --l5x "Path to your .L5X file"
```

**Parameters**

* `--acd` = path to your Studio 5000 project (.ACD)
* `--l5x` = path where the L5X file will be created

---

#### Step 2 — Explode (L5X → Structured Files)

Breaks the L5X into Git-friendly files.

```
.\l5xplode.exe explode `
  --l5x "Path to your .L5X file" `
  --dir "Path to your structured folder"
```

**Parameters**

* `--l5x` = path to the L5X file
* `--dir` = folder where structured files will be created

---

#### Step 3 — Commit (Save Version in Git)

```
git add .
git commit -m "initial commit"
```

---

#### Result

```
exploded-content/
  RSLogix5000Content/
```

---

## 🔹 Verify the Commit

```
git log --oneline
```

Example:

```
2f57557 initial commit
```

---

## 🔹 Optional: Rebuild the Exploded Project Manually

Once you have confirmed the commit, you can manually rebuild the exploded project content through PowerShell.

This is optional for the VCS workflow, but it is useful for learning and for proving that the exploded project content can be turned back into a rebuilt project artifact.

Run these commands from:

C:\Users\DevOps\ra-logix-designer-vcs-custom-tools\artifacts\bin\Release

Step 1 - Implode the Exploded Content into an L5X
.\l5xplode.exe implode `
  --dir "C:\Users\DevOps\Desktop\boiler-devops-demo\01-vcs\exploded-content" `
  --l5x "C:\Users\DevOps\Desktop\boiler-devops-demo\01-vcs\build\BoilerDemo_rebuilt.L5X"

Parameters

--dir = folder containing the exploded project files
--l5x = path where the rebuilt L5X file will be created
Step 2 - Convert the Rebuilt L5X into an ACD
.\l5xgit.exe l5x2acd `
  --l5x "C:\Users\DevOps\Desktop\boiler-devops-demo\01-vcs\build\BoilerDemo_rebuilt.L5X" `
  --acd "C:\Users\DevOps\Desktop\boiler-devops-demo\01-vcs\build\BoilerDemo_rebuilt.ACD"

Parameters

--l5x = path to the rebuilt L5X file
--acd = path where the rebuilt ACD file will be created
Result

You should now have:

01-vcs\build\BoilerDemo_rebuilt.L5X
01-vcs\build\BoilerDemo_rebuilt.ACD

This manual rebuild step is meant for local validation and learning.

For this demo, 01-vcs\build\ is a manual rebuild area, not the main source of truth.

---

## 🔹 Side-by-Side Summary

| Step    | Studio    | PowerShell           |
| ------- | --------- | -------------------- |
| Convert | automatic | acd2l5x              |
| Explode | automatic | l5xplode             |
| Commit  | automatic | git add + git commit |

---

## 🔹 Key Concept

```
explode = create files
commit = save a version in Git
```
