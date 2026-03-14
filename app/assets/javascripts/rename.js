/**
 * FileExplorer namespace
 */
window.fileExplorer = window.fileExplorer || {};

/**
 * Rename handler with improved error handling and modern JS patterns
 * @param {string} name - The current file/directory name to rename
 * @returns {Promise<boolean>} - Returns false to prevent default behavior
 */
window.fileExplorer.rename = async function(name) {
  const newName = prompt("Enter the new name for this element.", name);

  if (newName === null || newName === "") {
    return false;
  }

  if (newName === name) {
    console.warn("New name is the same as the original name");
    return false;
  }

  try {
    const response = await window.fileExplorer.sendRenameRequest(name, newName);

    if (response.ok) {
      window.location.reload();
    } else {
      console.error("Rename failed with status:", response.status);
      alert("Failed to rename the file/directory");
    }
  } catch (error) {
    console.error("Error during rename:", error);
    alert("An error occurred while renaming");
  }

  return false;
};

/**
 * Helper to send rename request via fetch API
 * @param {string} oldName - The old name
 * @param {string} newName - The new name
 * @returns {Promise<Response>} - Fetch response
 */
window.fileExplorer.sendRenameRequest = async function(oldName, newName) {
  const url = '/' + oldName;
  const formData = new FormData();
  formData.append("new_name", newName);

  // Add CSRF token
  const csrfToken = window.fileExplorer.getCsrfToken();
  const csrfParam = window.fileExplorer.getCsrfParam();
  if (csrfToken && csrfParam) {
    formData.append(csrfParam, csrfToken);
  }

  return fetch(url, {
    method: "PUT",
    body: formData,
    headers: {
      "X-Requested-With": "XMLHttpRequest"
    }
  });
};

/**
 * Get CSRF token from meta tags
 * @returns {string|null} CSRF token value or null
 */
window.fileExplorer.getCsrfToken = function() {
  const metaElement = document.querySelector("meta[name='csrf-token']");
  return metaElement ? metaElement.getAttribute("content") : null;
};

/**
 * Get CSRF param name from meta tags
 * @returns {string|null} CSRF param name or null
 */
window.fileExplorer.getCsrfParam = function() {
  const metaElement = document.querySelector("meta[name='csrf-param']");
  return metaElement ? metaElement.getAttribute("content") : null;
};
