# 📄 CVE Management App

This is an Elixir + Phoenix LiveView project developed by **Victoria Argañaras** as part of a technical challenge for **Wazuh**.

---

## 🎯 Project Goals

* Build a fullstack application to handle CVE (Common Vulnerabilities and Exposures) files in JSON format.
* Validate and persist uploaded CVE files.
* Display CVEs in a responsive user interface.
* Expose two API endpoints to:

  * List all CVEs.
  * Retrieve a specific CVE by its ID.
* Ensure application quality with unit and integration tests.

---

## 🚀 Getting Started

1. **Clone the repository** and navigate to the project directory:

   ```bash
   git clone https://github.com/your-username/cve_app.git
   cd cve_app
   ```

2. **Set up the project:**

   ```bash
   mix deps.get
   mix ecto.setup
   mix phx.server
   ```

3. **Visit the app:**

   Open your browser and navigate to [http://localhost:4000](http://localhost:4000)

---

## 🧪 What to Try

* Upload sample CVE files from `test/support`. Valid files will be saved; invalid files will return detailed error messages.

* Explore additional valid CVE JSONs from [https://cti.wazuh.com](https://cti.wazuh.com)

* Try the API endpoints:

  ```bash
  curl -i http://localhost:4000/api/cves
  curl -i http://localhost:4000/api/cves/CVE-2025-53624
  ```

* Run tests:

  ```bash
  mix test
  ```

* Check test coverage:

  ```bash
  mix coveralls.html && open cover/excoveralls.html
  ```

---

## 🧠 Design & Implementation

* CVE structure defined in the `Security` context:

  ```elixir
  %CVE{
    id: Ecto.UUID.t(),
    title: String.t(),
    cve_id: String.t(),
    publication_date: DateTime.t(),
    json_file: map(),
    inserted_at: DateTime.t(),
    updated_at: DateTime.t()
  }
  ```

* Validations are handled via `changeset/2`, ensuring data integrity.

* The `CVEManager` module provides core functionalities shared across the API and UI:

  * `create/1`
  * `get/1`
  * `get_by/1`
  * `list/0` and `list(fields)` (to return selected fields or all)

### 🖥️ UI Design

The user interface is fully responsive and designed to reflect Wazuh’s branding:

* 🎨 **Colors & gradients** match Wazuh’s palette.
* 🖋️ **Typography** mimics the company’s font style.
* 🧱 **Layout & navigation** inspired by wazuh.com.

Responsive previews:

* **Desktop** 

<img width="1422" height="710" alt="Desktop view" src="https://github.com/user-attachments/assets/ef4e4d9c-40a4-4cf8-8ec8-86cf97675ffe" />


* **Tablet**

 <img width="813" height="710" alt="Tablet view" src="https://github.com/user-attachments/assets/19f342d4-a647-4ffe-acb4-30c5081cefe7" />


* **Mobile** 

<img width="295" height="650" alt="Mobile view" src="https://github.com/user-attachments/assets/c9909af8-ab30-4ad5-a0a1-d88704e032ab" />

---

## 🧪 Testing Strategy

Tests are organized into:

* ✅ **Unit tests** for isolated functionality.
* 🔄 **Integration tests** simulating user interaction:

  * From an initial state (no CVEs uploaded).
  * After uploading one or more CVEs.
  * Handling invalid file uploads gracefully.

Test fixtures are located in `test/support`.

---

## 🙌 Final Thoughts

I hope this implementation meets your expectations for the challenge!
It was a great opportunity to showcase my skills in Elixir, Phoenix LiveView, and building reliable, user-friendly fullstack applications.

I'm looking forward to your feedback and the opportunity to move forward in the selection process. 🚀

