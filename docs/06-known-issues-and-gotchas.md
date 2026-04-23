Studio 5000 DevOps – Known Issues and Gotchas
Who This Is For

This document is for readers who already understand the basic VCS and CI flow and want the practical warning labels before they step on the same rake.

Read this after:

docs/01-vcs-setup.md
docs/02-ci-pipeline-setup.md
docs/03-ci-teststage.md

This is not a full troubleshooting guide.

It is a collection of the main practical lessons from setting up the Boiler DevOps Demo, especially the ones that affect:

version control
the VCS-to-CI handoff
Jenkins behavior
rebuild behavior
the Echo / Logix test stage
How to Use This Document

Use this document in two ways:

Before setup
Read it once so you know where the demo is a little sharp around the edges.
When something behaves strangely
Use it as a “have we seen this type of problem before?” reference before assuming the whole pipeline is broken.

The key idea is simple:

Not every failure means Jenkins is broken.
Not every green build means the whole architecture is perfect.
And not every weird result is your fault.

Sometimes the workflow really is a little weird. That is why this document exists.

Cross-Stage Gotchas

These are the lessons that cut across VCS, CI, and the test stage.

Exploded content in Git is the source of truth

For this demo, the source of truth is the exploded Studio 5000 content in the repo, not the generated .L5X, not the generated .ACD, and not a random file sitting on someone’s desktop. The setup notes repeatedly reinforced this repo-relative pattern because it made the pipeline easier to explain and reduced machine-specific path problems.

That means the important source-side path is:

01-vcs\exploded-content

Jenkins rebuilds from that content, not from the original ACD you happened to have open earlier.

Generated files are not source files

The generated .L5X and .ACD files are build/test artifacts. They are useful, but they are not the hand-maintained truth.

For this demo, generated output belongs under:

02-ci\generated\

Examples:

02-ci\generated\l5x\BoilerDemo_CI.l5x
02-ci\generated\acd\BoilerDemo_CI.ACD

That separation is one of the core architecture decisions in the CI notes.

Jenkins workspace is not your desktop repo

This caused real confusion during setup.

Jenkins runs against its workspace copy of the repo, not your desktop clone. So files created by the pipeline show up under the Jenkins workspace, not under C:\Users\DevOps\Desktop\boiler-devops-demo unless you copy them back yourself. The working notes called this out directly because it mattered for generated .L5X and .ACD files.

In the current working setup, the important Jenkins-side path is:

C:\Users\Jenkins\AppData\Local\Jenkins\.jenkins\workspace\BoilerDemo-CI\

If a file exists only on your desktop and the pipeline never sees it in the workspace, Jenkins does not care. Harsh, but consistent.

Build the pipeline in layers, not all at once

One of the best setup lessons was to bring the pipeline online in layers:

get Jenkins checking out the repo
get the harness restoring and building
wire in implode
wire in L5X-to-ACD
wire in Echo download and automated tests

That made it much easier to tell whether a problem lived in Jenkins, PowerShell, tool paths, or controller logic. This came directly from the CI setup notes and is worth preserving because it is practical, not theoretical.

VCS-to-CI Handoff Gotchas

These are the places where “the VCS side worked” does not automatically mean “the CI result will behave exactly the way you expect.”

A successful explode/commit does not guarantee rebuild semantics are perfect

The VCS side can succeed cleanly:

ACD exported
L5X created
content exploded
Git commit created

and you can still learn something new only when CI tries to rebuild and test the result.

That is not a contradiction. It is the whole reason the CI stage exists.

Deletions need extra validation

This is one of the most important current gotchas.

A deletion made in the Studio 5000 source did make it into the exploded content, but the downstream generated result did not clearly reflect that deletion the way expected. The working theory is that when l5x2acd is applying changes against an existing seed ACD, additions and edits may flow more cleanly than full removals.

So the doc set should say this plainly:

additions and edits appear more straightforward
deletions should be treated as a known validation area
when the rebuild is based on an existing ACD seed, full removals need extra verification

This should be documented as a current limitation/gotcha, not as a final proven product limitation.

What Jenkins rebuilds from is the exploded content, not the original ACD

This sounds obvious once stated, but it is easy to mentally drift back toward “the ACD is the real thing.”

For this demo, the rebuild story is:

exploded content in Git -> generated L5X -> generated/update-target ACD -> test harness

That means a change that appears correct in the source ACD matters only once it has actually made it into the exploded content that Jenkins will consume.

Revert is the safer recovery story than rewriting history

For demo purposes, the cleaner recovery flow after a bad change is:

push the bad change
let CI fail
create a new commit that restores the good state
push again
let CI rerun

That is a better teaching story than force-pushing or hiding the mistake. It teaches version control and CI together in a way beginners can actually follow.

CI Pipeline Gotchas

These are the practical problems and lessons that show up in the Jenkins / script / rebuild layer.

Jenkins is orchestration, not logic

This is one of the biggest concepts from the setup notes.

Jenkins does not “do Echo” or “do Logix” by itself. It orchestrates a set of scripts and applications that already have to work. The earlier notes summarized it cleanly: Jenkins is orchestration, not logic.

That means:

broken harness code stays broken in Jenkins
broken tool paths stay broken in Jenkins
Jenkins is not a magical repair service
The Jenkinsfile should stay thin

The working setup was much cleaner when the Jenkinsfile defined:

stage order
repo-relative paths
tool locations
which scripts run

and left the real work inside PowerShell scripts. That kept the pipeline readable and made each stage easier to test locally.

If the Jenkinsfile starts turning into a PowerShell/Groovy lasagna, things usually get worse, not better.

Use repo-relative paths for content

The pipeline worked best when the repo structure was treated as the source of truth for:

exploded content
generated L5X
generated ACD
scripts
test harness solution

This reduced hardcoded machine-path confusion and made the demo easier to explain.

External tool paths should be explicit

The working setup used explicit full paths for:

l5xplode.exe
l5xgit.exe

instead of assuming those tools were magically on PATH. That made the pipeline more repeatable and easier for beginners to follow.

In the current working setup, those explicit paths are:

C:\Users\DevOps\ra-logix-designer-vcs-custom-tools\artifacts\bin\Release\l5xplode.exe
C:\Users\DevOps\ra-logix-designer-vcs-custom-tools\artifacts\bin\Release\l5xgit.exe

Not glamorous, but honest.

Use Join-Path in PowerShell instead of clever path strings

One of the more annoying setup problems came from trying to build Windows paths through layered Jenkins/Groovy/PowerShell string manipulation. The working Jenkinsfile had to switch to Join-Path inside PowerShell because the earlier approach caused Jenkins to try to execute the workspace folder as if it were the script. That is a ridiculous bug to debug in a beginner demo.

Practical lesson:

use explicit, readable path handling
do not get cute with slash replacement inside nested strings
run-ci-tests.ps1 should own restore, build, and run

This ended up being cleaner than splitting those steps between Jenkins and the script.

Letting run-ci-tests.ps1 own:

dotnet restore
dotnet build
dotnet run

kept the Jenkinsfile simpler and made the test stage easier to reason about. That was one of the concrete setup lessons.

Runtime arguments beat hardcoded paths

The console app originally hardcoded the ACD location. For CI, it needed to accept the ACD path as an argument so Jenkins could pass the generated file into the harness. That is a strong beginner lesson:

hardcoded paths are fine for a fast local proof of concept
CI needs runtime-driven inputs
Rebuild and Artifact Gotchas

These are the specific weird edges around generating .L5X and .ACD.

l5x2acd currently behaves like an update step

This is one of the biggest gotchas in the demo.

Observed behavior strongly suggested that l5xgit l5x2acd expects an existing .ACD file at the target path. When the pipeline was given a brand-new output path, it complained that --acd had to point to a file that already existed. Once an ACD was present at the workspace output path, the pipeline got past that stage.

So the current workflow should be described as:

existing ACD + generated L5X -> updated/generated ACD

not as:

nothing -> brand-new ACD

That is not a tiny wording difference. It changes what claims the public demo can honestly make.

The long-term home of the seed ACD is still a design decision

The notes called out that a cleaner repo design would likely put the seed ACD in a clearer source location like:

01-vcs\acd-source\BoilerDemo.ACD

But in the working demo, the practical fact was simpler: an ACD had to exist at the Jenkins workspace output location for the stage to get through.

So the current demo works, but the architectural story is still maturing a bit.

Test-Stage and Environment Gotchas

These are the issues and lessons tied to Echo, Logix, FTSP, and the runtime behavior of the harness.

Echo is an external dependency, not part of the build

Echo is not part of the compile/build step. It is an external dependency the pipeline assumes exists and can use. The earlier notes were very clear that CI does not “start the whole system from nothing”; it verifies required services and then runs the test flow against them.

That means this is an integration-style test stage, not a tiny isolated unit test.

CI does not reset environment state for you

Controllers can persist in Echo between runs. Slots can remain occupied. State may survive from earlier runs.

That is why the provisioning logic had to handle existing state gracefully rather than assuming a perfectly clean environment every time. The earlier notes explicitly called out slot-aware provisioning as more reliable than just “create from ACD and hope.”

Authentication and environment context are not normal CI assumptions

This setup is not a simple token-based API workflow. The setup notes pointed out that FactoryTalk-related authentication depends on environment configuration and Windows execution context. Manual runs could work while Jenkins service runs did not. The same code could later succeed without source changes, which points to session or environment sensitivity rather than straightforward code bugs.

The practical wording for the docs should be simple:

CI runs involving FTSP / Logix Designer SDK may be sensitive to Windows user/session context. That is an environment consideration, not just a code problem.

Flat atomic tags are a deliberate design choice

The current harness uses flat controller-scoped tags like:

Tank1_ValveInStatus
Tank1_ValveInCmd
Tank1_ValveOutStatus
Tank1_ValveOutCmd
Tank1_Level
Tank1_SetPoint

and matching tags for Tank2. The earlier notes showed that flat atomic tags worked reliably with LDSDK online read/write methods, while direct UDT member access was much less practical for a beginner-first public demo.

So this is not a hack. It is a deliberate demo design choice.

The automated tests are functional checks, not full plant simulation

The current tests validate simple controller behavior such as:

inlet opens below setpoint
inlet stays closed at setpoint
outlet opens above zero
outlet stays closed at zero

That is enough to prove the CI stage is validating real logic behavior, even though it is not trying to be a complete process simulation.

A red build can mean the demo is working

One of the most useful results from the working setup was that once Jenkins, PowerShell, tool paths, Echo, and the harness were all functioning, failures became much more meaningful. At that point, a failed build no longer meant “CI is broken.” It could mean a missing logic rule, a wrong expectation, or a real mismatch between intended behavior and actual controller behavior.

The first useful end-to-end run reportedly passed six tests and failed two outlet-open checks. That is exactly the kind of failure a good CI demo should surface.

Repo Hygiene Gotchas

These are boring, but boring problems waste a lot of time.

Keep junk out of source control

The earlier setup lessons called out:

.vs
bin
obj

as things that must be ignored and removed from tracking. Otherwise, Windows path length issues and checkout weirdness can break the pipeline before the actual demo logic even runs.

At minimum, .gitignore should cover:

.vs/
**/bin/
**/obj/

This is not exciting, but it saves pain.

Clean structure makes the demo easier to teach

By the end of setup, the repo structure supported teaching because a beginner could see:

where source content lives
where generated CI artifacts go
what Jenkins runs
what each PowerShell script does
what the test harness is checking

That is a feature, not an accident.

Recovery Patterns That Are Safer

These are the “when things go wrong, do this instead of making it worse” patterns.

Safer recovery pattern after a bad change

Use this flow:

commit and push the bad change
let CI fail
make a new commit restoring the good state
push again
let CI rerun

That keeps the history honest and teaches the real CI/VCS loop.

Safer way to debug stage failures

When a stage fails, isolate it:

checkout problem -> Jenkins / SCM / branch / credentials
restore problem -> .NET / solution / package resolution
build problem -> source / project references / dependencies
runtime problem -> ACD / Echo / Logix / environment
behavioral failure -> controller logic or test expectations

That layered view came directly from the setup effort and is one of the best practical habits the doc set can teach.

What Not to Overemphasize

The setup notes explicitly warned against letting the docs get dominated by:

every auth failure
every Jenkins cache annoyance
every service-wrapper quirk
every experimental UDT path guess

That is the right instinct.

Those things matter, but they belong in a gotchas reference like this one, not as the backbone of the beginner setup docs.