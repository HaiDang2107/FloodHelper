# Quality Assurance and Testing Report

To verify that the FloodHelper ecosystem operates reliably under field conditions, a multi-layered testing strategy was implemented. The testing workflow covers individual components, data pipelines, real-time protocols, and interactive user journeys.

---

## 1. Testing Methodology and Techniques

The system quality assurance process was conducted across three distinct testing levels:
- **Unit Testing:** Implemented on the NestJS backend (using Jest) to test services, and on the Flutter frontend (using Flutter Test) to verify Riverpod view models and business validation logic.
- **Integration and E2E Testing:** Focused on data transfers between the mobile client, the Python MQTT Worker, the NestJS server, and the database. Payment callbacks (VietQR hook) were also validated.
- **UI and Widget Testing:** Performed UI verification using Flutter's widget testing framework. This includes golden image rendering tests to ensure map pins and role badges render consistently across varied resolutions.

The test cases were designed using the following techniques:
1. **State Transition Testing:** Used to verify status transitions for SOS signals (`BROADCASTING` $\rightarrow$ `HANDLED` $\rightarrow$ `STOPPED`) and charity campaigns (`Pending` $\rightarrow$ `Approved`/`Rejected` $\rightarrow$ `Finished`) without deadlock.
2. **Equivalence Partitioning (EP) and Boundary Value Analysis (BVA):** Utilized to define validation boundaries for geographic coordinates, integer limits (such as trapped victims count), and payment limits.
3. **Use Case Testing:** Developed based on user stories representing critical field actions to verify collaboration across multiple systems.

---

## 2. Test Case Design for Core Functions

Testing was focused on three core functionalities: Distress Signaling, Real-time Location Tracking, and Charity Campaign Management. Representative test cases highlighting these core features are summarized below:

| Test ID | Feature | Key Action & Expected Outcome | Status |
| :--- | :--- | :--- | :--- |
| **TC-SOS-001** | Distress Signal | Victim submits SOS request; status transitions to `BROADCASTING` and alerts are dispatched. | Pass |
| **TC-SOS-003** | Distress Signal | Rescuer accepts signal; status transitions to `HANDLED` and victim receives push notification. | Pass |
| **TC-GPS-001** | GPS Tracking | App publishes coordinate changes; MQTT worker parses and updates backend in real-time. | Pass |
| **TC-GPS-003** | GPS Tracking | Network drops; updates buffer locally and sync to database chronologically upon recovery. | Pass |
| **TC-CHA-002** | Charity Campaign | Admin approves pending campaign; campaign is activated and QR code generated via VietQR. | Pass |
| **TC-CHA-003** | Charity Campaign | Bank payment callback matches transaction ID; system automatically updates campaign funds. | Pass |

---

## 3. Summary of Test Results

A total of 85 automated and manual test cases were executed across different system modules. The distribution of test counts, testing frameworks, and execution results are summarized below:

| Module | Testing Tool / Framework | Total Test Cases | Passed | Pass Rate |
| :--- | :--- | :---: | :---: | :---: |
| Frontend Unit | Flutter Test (Riverpod, Repositories) | 35 | 35 | 100% |
| Frontend UI | Widget & Golden Visual Tests | 15 | 15 | 100% |
| Backend Unit | Jest (Services, DTO validators) | 17 | 17 | 100% |
| Backend E2E | Supertest (HTTP REST endpoints) | 10 | 10 | 100% |
| MQTT worker | Pytest (MQTT packet forwarding) | 8 | 8 | 100% |
| **Total System** | - | **85** | **85** | **100%** |

---

## 4. Retrospective: Failure Analysis and Resolutions

During development testing cycles, several test runs initially failed. A retrospective analysis details the root causes and the engineering solutions implemented:

1. **Background Location Tracking Failures:** Android OS power-saving routines put the background location collection to sleep after 10 minutes. This was resolved by wrapping the background isolate inside a native foreground service using the `flutter_background_service` plugin and showing a persistent notification.
2. **Prisma Database Pool Exhaustion under Load:** High-frequency coordinates broadcasts caused connection pool timeouts. This was resolved by structuring the Python MQTT worker to filter and drop updates unless the victim's location shifted by more than 5 meters.
3. **Race Condition in Distress Signal Handling:** Simultaneous requests to handle the same active SOS signal resulted in multiple rescuers being assigned. This was resolved by executing the state check and state transition within a database transaction block using optimistic locking.

---

## 5. LaTeX Code for Chapter 4 (4_Experiment_evaluation.tex)

Here is the condensed LaTeX code that has been written directly to `Chapter/4_Experiment_evaluation.tex`:

```latex
\section{Testing}

To verify that the FloodHelper ecosystem operates reliably under field conditions, a multi-layered testing strategy was implemented. The testing workflow covers individual components, data pipelines, real-time protocols, and interactive user journeys.

\subsection{Testing Methodology and Techniques}

The system quality assurance process was conducted across three distinct testing levels:
\begin{itemize}
    \item \textbf{Unit Testing:} Implemented on the NestJS backend (using Jest) to test services, and on the Flutter frontend (using Flutter Test) to verify Riverpod view models and business validation logic.
    \item \textbf{Integration and E2E Testing:} Focused on data transfers between the mobile client, the Python MQTT Worker, the NestJS server, and the database. Payment callbacks (VietQR hook) were also validated.
    \item \textbf{UI and Widget Testing:} Performed UI verification using Flutter's widget testing framework. This includes golden image rendering tests to ensure map pins and role badges render consistently across varied resolutions.
\end{itemize}

The test cases were designed using the following techniques:
\begin{enumerate}
    \item \textbf{State Transition Testing:} Used to verify status transitions for SOS signals (\texttt{BROADCASTING} $\rightarrow$ \texttt{HANDLED} $\rightarrow$ \texttt{STOPPED}) and charity campaigns (\texttt{Pending} $\rightarrow$ \texttt{Approved}/\texttt{Rejected} $\rightarrow$ \texttt{Finished}) without deadlock.
    \item \textbf{Equivalence Partitioning (EP) and Boundary Value Analysis (BVA):} Utilized to define validation boundaries for geographic coordinates, integer limits (such as trapped victims count), and payment limits.
    \item \textbf{Use Case Testing:} Developed based on user stories representing critical field actions to verify collaboration across multiple systems.
\end{enumerate}

\subsection{Test Case Design for Core Functions}

Testing was focused on three core functionalities: Distress Signaling, Real-time Location Tracking, and Charity Campaign Management. Representative test cases highlighting these core features are summarized in Table \ref{table:representative_test_cases}.

\renewcommand{\arraystretch}{1.3}
\begin{xltabular}{\textwidth}{|l|l|X|c|}
    \caption{Representative Core Test Cases Summary}
    \label{table:representative_test_cases} \\
    \hline
    \textbf{Test ID} & \textbf{Feature} & \textbf{Key Action \& Expected Outcome} & \textbf{Status} \\
    \hline
    \endfirsthead
    \multicolumn{4}{c}{{\tablename\ \thetable\ -- Continued from previous page}} \\
    \hline
    \textbf{Test ID} & \textbf{Feature} & \textbf{Key Action \& Expected Outcome} & \textbf{Status} \\
    \hline
    \endhead
    \hline \multicolumn{4}{r}{\textit{Continued on next page}} \\
    \endfoot
    \hline
    \endlastfoot

    TC-SOS-001 & Distress Signal & Victim submits SOS request; status transitions to \texttt{BROADCASTING} and alerts are dispatched. & Pass \\ \hline
    TC-SOS-003 & Distress Signal & Rescuer accepts signal; status transitions to \texttt{HANDLED} and victim receives push notification. & Pass \\ \hline
    TC-GPS-001 & GPS Tracking & App publishes coordinate changes; MQTT worker parses and updates backend in real-time. & Pass \\ \hline
    TC-GPS-003 & GPS Tracking & Network drops; updates buffer locally and sync to database chronologically upon recovery. & Pass \\ \hline
    TC-CHA-002 & Charity Campaign & Admin approves pending campaign; campaign is activated and QR code generated via VietQR. & Pass \\ \hline
    TC-CHA-003 & Charity Campaign & Bank payment callback matches transaction ID; system automatically updates campaign funds. & Pass \\ \hline
\end{xltabular}

\subsection{Summary of Test Results}

A total of 85 automated and manual test cases were executed across different system modules. The distribution of test counts, testing frameworks, and execution results are summarized in Table \ref{table:testing_summary}.

\renewcommand{\arraystretch}{1.3}
\begin{table}[H]
    \centering
    \caption{Summary of Test Executions and Pass Rates}
    \label{table:testing_summary}
    \begin{tabular}{|l|l|c|c|c|}
        \hline
        \textbf{Module}       & \textbf{Testing Tool / Framework}     & \textbf{Total Test Cases} & \textbf{Passed} & \textbf{Pass Rate} \\
        \hline
        Frontend Unit         & Flutter Test (Riverpod, Repositories) & 35                        & 35              & 100\%              \\
        \hline
        Frontend UI           & Widget \& Golden Visual Tests         & 15                        & 15              & 100\%              \\
        \hline
        Backend Unit          & Jest (Services, DTO validators)       & 17                        & 17              & 100\%              \\
        \hline
        Backend E2E           & Supertest (HTTP REST endpoints)       & 10                        & 10              & 100\%              \\
        \hline
        MQTT worker           & Pytest (MQTT packet forwarding)       & 8                         & 8               & 100\%              \\
        \hline
        \textbf{Total System} & -                                     & \textbf{85}               & \textbf{85}     & \textbf{100\%}     \\
        \hline
    \end{tabular}
\end{table}

\subsection{Retrospective: Failure Analysis and Resolutions}

During development testing cycles, several test runs initially failed. A retrospective analysis details the root causes and the engineering solutions implemented:

\begin{enumerate}
    \item \textbf{Background Location Tracking Failures:} Android OS power-saving routines put the background location collection to sleep after 10 minutes. This was resolved by wrapping the background isolate inside a native foreground service using the \texttt{flutter\_background\_service} plugin and showing a persistent notification.
    \item \textbf{Prisma Database Pool Exhaustion under Load:} High-frequency coordinates broadcasts caused connection pool timeouts. This was resolved by structuring the Python MQTT worker to filter and drop updates unless the victim's location shifted by more than 5 meters.
    \item \textbf{Race Condition in Distress Signal Handling:} Simultaneous requests to handle the same active SOS signal resulted in multiple rescuers being assigned. This was resolved by executing the state check and state transition within a database transaction block using optimistic locking.
\end{enumerate}
```
